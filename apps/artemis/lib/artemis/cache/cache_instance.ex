defmodule Artemis.CacheInstance do
  use GenServer, restart: :transient

  import Cachex.Spec

  require Logger

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

  # Server Callbacks

  def start_link(options) do
    module = Keyword.fetch!(options, :module)

    initial_state = %{
      cachex_instance_name: get_cachex_instance_name(module),
      cachex_options: Keyword.get(options, :cachex_options, []),
      cache_server_name: get_cache_server_name(module),
      cache_reset_on_events: Keyword.get(options, :cache_reset_on_events, [])
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
  Fetches key from the cache. If it exists, the value is returned. If it does
  not exist in the cache, the `getter` function is called. The result is returned
  to the user. The result is stored in the cache unless it is an error.
  """
  def fetch(module, key, getter) do
    case get(module, key) do
      {:ok, nil} ->
        Logger.debug("#{get_cache_server_name(module)}: cache miss")

        put(module, key, getter.())

      {:ok, value} ->
        Logger.debug("#{get_cache_server_name(module)}: cache hit")

        value
    end
  end

  @doc """
  Gets the key from the cache. If it does not exist, returns `nil`.
  """
  def get(module, key), do: GenServer.call(get_cache_server_name(module), {:get, key})

  @doc """
  Puts value into the cache, unless it is an error tuple
  """
  def put(_module, _key, {:error, message}), do: %CacheEntry{data: {:error, message}}

  def put(module, key, value) do
    inserted_at = DateTime.utc_now() |> DateTime.to_unix()
    entry = %CacheEntry{data: value, inserted_at: inserted_at, key: key}

    GenServer.call(get_cache_server_name(module), {:put, key, entry})
  end

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
  def reset(module), do: stop(module)

  @doc """
  Stop the cache GenServer and the linked Cachex process
  """
  def stop(module), do: GenServer.stop(get_cache_server_name(module))

  # Instance Callbacks

  @impl true
  def init(initial_state) do
    :ok = subscribe_to_events(initial_state)

    cachex_options = create_cachex_options(initial_state)

    {:ok, cachex_instance_pid} = create_cachex_instance(initial_state, cachex_options)

    state =
      initial_state
      |> Map.put(:cachex_instance_pid, cachex_instance_pid)
      |> Map.put(:cachex_options, cachex_options)

    {:ok, state}
  end

  @impl true
  def handle_call(:cachex_options, _from, state) do
    {:reply, state.cachex_options, state}
  end

  def handle_call({:get, key}, _from, state) do
    result = Cachex.get(state.cachex_instance_name, key)

    {:reply, result, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    # Call the put function in a separate task to minimize potential memory
    # growth in GenServer.
    #
    # See: https://elixirforum.com/t/extremely-high-memory-usage-in-genservers/4035/27
    task = Task.async(fn -> Cachex.put(state.cachex_instance_name, key, value) end)
    {:ok, _} = Task.await(task)

    {:reply, value, state}
  end

  @impl true
  def handle_info(%{event: event}, state) do
    case Enum.member?(state.cache_reset_on_events, event) do
      true ->
        Logger.debug("#{state.cachex_instance_name}: Cache reset by event #{event}")

        {:stop, :normal, state}

      false ->
        {:noreply, state}
    end
  end

  # Helpers

  defp subscribe_to_events(_state) do
    topic = Artemis.Event.get_broadcast_topic()

    ArtemisPubSub.subscribe(topic)
  end

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
end
