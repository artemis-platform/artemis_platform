defmodule Artemis.CacheInstance do
  use GenServer, restart: :transient

  import Cachex.Spec

  require Logger

  alias Artemis.CacheEvent

  defmodule CacheEntry do
    defstruct [:data, :inserted_at, :key]
  end

  @moduledoc """
  A thin wrapper around a Cachex instance. Encapsulates all the application
  specific logic like subscribing to events, reseting cache values automatically.

  ## GenServer Configuration

  By default the `restart` value of a GenServer child is `:permanent`. This is
  perfect for the common scenario where child processes should always be
  restarted.

  In the case of a cache instance, each is created dynamically only when
  needed. There may be cases where a cache instance is no longer needed, and
  should be shut down. To enable this, the CacheInstance uses the `:transient`
  value. This ensures the cache is only restarted if it was shutdown abnormally.

  For more information on see the [Supervisor Documentation](https://hexdocs.pm/elixir/1.8.2/Supervisor.html#module-restart-values-restart).

  ## Preventing Cache Stampeding

  When the cache is empty, the first call to `fetch()` will execute the
  `getter` function and insert the result into the cache.

  While the initial `getter` function is being evaluated but not yet completed,
  any additional calls to `fetch` will also see an empty cache and start
  executing the `getter` function. While inefficient, this duplication is
  especially problematic if the getter function is expensive or takes a long time
  to execute.

  The GenServer can be used as a simple queuing mechanism to prevent this
  "thundering herd" scenario and ensure the `getter` function is only executed
  once.

  Since all GenServer callbacks are blocking, any additional calls to the
  cache that are received while the `getter` function is being executed will be
  queued until after the initial call completes.

  With the `getter` execution completed and the value stored in the cached, all
  subsequent calls in the queue can read directly from the cache.

  Since the cache can support many different values under different keys, it's
  important to note the `fetch` function will never queue requests for keys
  that are already present in the cache. Only requests for keys that are
  currently empty will be queued.
  """

  @default_cachex_options [
    expiration:
      expiration(
        default: :timer.minutes(5),
        interval: :timer.seconds(5)
      ),
    limit: 100,
    stats: true
  ]

  @fetch_timeout :timer.seconds(120)

  # Server Callbacks

  def start_link(options) do
    module = Keyword.fetch!(options, :module)

    initial_state = %{
      cachex_instance_name: get_cachex_instance_name(module),
      cachex_options: Keyword.get(options, :cachex_options, []),
      cache_server_name: get_cache_server_name(module),
      cache_reset_on_events: Keyword.get(options, :cache_reset_on_events, []),
      module: module
    }

    GenServer.start_link(__MODULE__, initial_state, name: initial_state.cache_server_name)
  end

  # Server Functions

  @doc """
  Detect if the cache instance GenServer has been started
  """
  def started?(module) do
    name = get_cache_server_name(module)

    cond do
      Process.whereis(name) -> true
      :global.whereis_name(name) != :undefined -> true
      true -> false
    end
  end

  @doc """
  Fetch the key from the cache instance. If it exists, return the value.
  If it does not, evaluate the `getter` function and cache the result.

  If the `getter` function returns a `{:error, _}` tuple, it will not
  be stored in the cache.
  """
  def fetch(module, key, getter) do
    case get_from_cache(module, key) do
      nil ->
        Logger.debug("#{get_cachex_instance_name(module)}: cache miss")

        GenServer.call(get_cache_server_name(module), {:fetch, key, getter}, @fetch_timeout)

      value ->
        Logger.debug("#{get_cachex_instance_name(module)}: cache hit")

        value
    end
  end

  @doc """
  Gets the key from the cache instance. If it does not exist, returns `nil`.
  """
  def get(module, key), do: get_from_cache(module, key)

  @doc """
  Puts value into the cache, unless it is an error tuple. If it is a function, evaluate it
  """
  def put(module, key, value), do: put_in_cache(module, key, value)

  def get_cache_server_name(module), do: String.to_atom("#{module}.CacheServer")

  def get_cachex_instance_name(module), do: String.to_atom("#{module}.CachexInstance")

  def get_cachex_options(module), do: GenServer.call(get_cache_server_name(module), :cachex_options)

  def get_name(module), do: get_cache_server_name(module)

  def default_cachex_options, do: @default_cachex_options

  @doc """
  Determines if a cache server has been created for the given module
  """
  def exists?(module), do: Enum.member?(Process.registered(), get_cache_server_name(module))

  @doc """
  Clear all cache data
  """
  def reset(module) do
    stop(module)

    :ok = CacheEvent.broadcast("cache:reset", module)
  end

  @doc """
  Stop the cache GenServer and the linked Cachex process
  """
  def stop(module) do
    GenServer.stop(get_cache_server_name(module))

    :ok = CacheEvent.broadcast("cache:stopped", module)
  end

  # Instance Callbacks

  @impl true
  def init(initial_state) do
    cachex_options = create_cachex_options(initial_state)

    {:ok, cachex_instance_pid} = create_cachex_instance(initial_state, cachex_options)

    state =
      initial_state
      |> Map.put(:cachex_instance_pid, cachex_instance_pid)
      |> Map.put(:cachex_options, cachex_options)

    subscribe_to_events(initial_state)

    :ok = CacheEvent.broadcast("cache:started", initial_state.module)

    {:ok, state}
  end

  @impl true
  def handle_call(:cachex_options, _from, state) do
    {:reply, state.cachex_options, state}
  end

  def handle_call({:fetch, key, getter}, _from, state) do
    entry = fetch_from_cache(state.module, key, getter)

    {:reply, entry, state}
  end

  @impl true
  def handle_info(%{event: event, payload: payload}, state), do: process_event(event, payload, state)

  # Cachex Helpers

  defp get_from_cache(module, key) do
    cachex_instance_name = get_cachex_instance_name(module)

    Cachex.get!(cachex_instance_name, key)
  rescue
    _ -> nil
  end

  defp put_in_cache(_module, _key, {:error, message}), do: %CacheEntry{data: {:error, message}}

  defp put_in_cache(module, key, value) do
    cachex_instance_name = get_cachex_instance_name(module)
    inserted_at = DateTime.utc_now() |> DateTime.to_unix()

    entry = %CacheEntry{
      data: value,
      inserted_at: inserted_at,
      key: key
    }

    {:ok, _} = Cachex.put(cachex_instance_name, key, entry)

    entry
  end

  defp fetch_from_cache(module, key, getter) do
    cachex_instance_name = get_cachex_instance_name(module)

    case get_from_cache(module, key) do
      nil ->
        Logger.debug("#{cachex_instance_name}: fetch - updating cache")

        put_in_cache(module, key, getter.())

      value ->
        Logger.debug("#{cachex_instance_name}: fetch - cache hit")

        value
    end
  end

  # Helpers - Events

  defp subscribe_to_events(%{cache_reset_on_events: events}) when length(events) > 0 do
    topic = Artemis.Event.get_broadcast_topic()

    :ok = ArtemisPubSub.subscribe(topic)
  end

  defp subscribe_to_events(_state), do: :skipped

  defp process_event(event, payload, state) do
    case Enum.member?(state.cache_reset_on_events, event) do
      true -> reset_cache(state, payload)
      false -> {:noreply, state}
    end
  end

  # Helpers

  defp create_cachex_options(state) do
    passed_options = convert_expiration_option(state.cachex_options)

    Keyword.merge(default_cachex_options(), passed_options)
  end

  defp create_cachex_instance(state, options) do
    Cachex.start_link(state.cachex_instance_name, options)
  end

  defp convert_expiration_option([{:expiration, value} | _] = options) do
    converted =
      expiration(
        default: value,
        interval: :timer.seconds(5)
      )

    Keyword.put(options, :expiration, converted)
  end

  defp convert_expiration_option(options), do: options

  defp reset_cache(state, event) do
    :ok = CacheEvent.broadcast("cache:reset", state.module, event)

    Logger.debug("#{state.cachex_instance_name}: Cache reset by event #{event}")

    {:stop, :normal, state}
  end
end
