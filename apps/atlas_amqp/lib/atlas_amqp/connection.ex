defmodule AtlasAmqp.Connection do
  use GenServer
  use AMQP

  @exchange "atlas_exchange"
  @queue "atlas_queue"
  @reconnect_interval 10000

  defmodule State do
    defstruct [
      connection: nil
    ]
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, connection} = connect()

    setup_queues(connection, @exchange, @queue)

    state = %State{connection: connection}

    {:ok, state}
  end

  # Interface

  def open_channel() do
    GenServer.call(__MODULE__, :open_channel)
  end

  def close_channel(channel) do
    Channel.close(channel)
  end

  # Callbacks

  def handle_call(:open_channel, _from, state) do
    {:reply, Channel.open(state.connection), state}
  end

  # Reconnect when system sends DOWN notification
  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    {:ok, connection} = connect()

    {:noreply, %State{state|connection: connection}}
  end
  def handle_info(_request, state) do
    {:noreply, state}
  end

  # Helpers

  defp connect() do
    case Connection.open(connection_uri()) do
      {:ok, connection} ->
        Process.monitor(connection.pid)
        {:ok, connection}
      {:error, msg} ->
        :timer.sleep(@reconnect_interval)
        connect()
    end
  end

  defp connection_uri do
    config = Application.get_env(:atlas_amqp, :connection)

    user = Keyword.fetch!(config, :username)
    pass = Keyword.fetch!(config, :password)
    host = Keyword.fetch!(config, :host)
    port = Keyword.fetch!(config, :port)
    virtual_host = String.trim(Keyword.fetch!(config, :virtual_host), "/")

    ssl_options = Keyword.fetch!(config, :ssl_options)
    ssl_enabled = Keyword.fetch!(ssl_options, :enabled) === "true"
    protocol = if ssl_enabled, do: "amqps", else: "amqp"

    # "#{protocol}://#{user}:#{pass}@#{host}:#{port}/#{virtual_host}"
    "#{protocol}://#{user}:#{pass}@#{host}:#{port}"
  end

  defp setup_queues(connection, exchange, queue) do
    {:ok, channel} = Channel.open(connection)

    queue_error = "#{queue}_error"

    # Error Queue
    {:ok, _} = Queue.declare(channel, queue_error, durable: true)

    # Message Queue
    # Messages that cannot be delivered to any consumer in the main queue will
    # be routed to the error queue
    {:ok, _} = Queue.declare(channel, queue, durable: true,
      arguments: [
        {"x-dead-letter-exchange", :longstr, ""},
        {"x-dead-letter-routing-key", :longstr, queue_error}
      ]
    )

    :ok = Exchange.fanout(channel, exchange, durable: true)
    :ok = Queue.bind(channel, queue, exchange)
  end
end
