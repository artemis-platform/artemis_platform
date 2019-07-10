defmodule Artemis.CacheInstance do
  use GenServer, restart: :transient

  import Cachex.Spec

  require Logger

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

  # Server Callbacks

  def start_link(options) do
    module = Keyword.fetch!(options, :module)

    initial_state = %{
      cachex_instance_name: get_cachex_instance_name(module),
      cache_server_name: get_cache_server_name(module),
      cache_reset_events: Keyword.get(options, :cache_reset_events, [])
    }

    GenServer.start_link(__MODULE__, initial_state, name: initial_state.cache_server_name)
  end

  # Server Functions

  @doc """
  Fetches key from the cache. If it exists, the value is returned. If it does
  not exist in the cache, the `getter` function is called, the result is returned
  to the user, and stored in the cache for future calls.
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
  Puts a value in the cache
  """
  def put(module, key, value), do: GenServer.call(get_cache_server_name(module), {:put, key, value})

  def get_name(module), do: get_cache_server_name(module)

  def get_cache_server_name(module), do: String.to_atom("#{module}.CacheServer")

  def get_cachex_instance_name(module), do: String.to_atom("#{module}.CachexInstance")

  @doc """
  Determines if a cache server has been created for the given module
  """
  def exists?(module), do: Enum.member?(Process.registered(), get_cache_server_name(module))

  # Instance Callbacks

  @impl true
  def init(initial_state) do
    :ok = subscribe_to_events(initial_state)

    {:ok, cachex_instance_pid} = create_cachex_instance(initial_state)

    state = Map.put(initial_state, :cachex_instance_pid, cachex_instance_pid)

    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    result = Cachex.get(state.cachex_instance_name, key)

    {:reply, result, state}
  end

  def handle_call({:put, key, value}, _from, state) do
    {:ok, _} = Cachex.put(state.cachex_instance_name, key, value)

    {:reply, value, state}
  end

  @impl true
  def handle_info(%{event: event}, state) do
    if Enum.member?(state.cache_reset_events, event) do
      Logger.debug("#{state.cachex_instance_name}: Cache reset by event #{event}")

      {:ok, _} = Cachex.clear(state.cachex_instance_name)
    end

    {:noreply, state}
  end

  # Helpers

  defp subscribe_to_events(_state) do
    topic = Artemis.Event.get_broadcast_topic()

    ArtemisPubSub.subscribe(topic)
  end

  defp create_cachex_instance(state) do
    cachex_instance_options = [
      expiration:
        expiration(
          default: :timer.minutes(5),
          interval: :timer.seconds(5)
        ),
      limit: 100,
      stats: true
    ]

    Cachex.start_link(state.cachex_instance_name, cachex_instance_options)
  end
end
