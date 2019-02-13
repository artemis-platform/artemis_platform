defmodule AtlasAmqp.Consumer do
  use GenServer
  use AMQP

  @default_exchange "atlas_exchange"
  @default_queue "atlas_queue"
  @reconnect_interval 10000

  defmodule State do
    defstruct [
      channel: nil,
      exchange: nil,
      queue: nil
    ]
  end

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(options \\ %{}) do
    exchange = Map.get(options, :exchange, @default_exchange)
    queue = Map.get(options, :queue, @default_queue)
    {:ok, channel} = get_channel(queue)

    state = %State{channel: channel, exchange: exchange, queue: queue}

    {:ok, state}
  end

  # Callbacks

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, state) do
    spawn fn -> consume(state.channel, tag, redelivered, payload) end
    {:noreply, state}
  end

  # Reconnect when system sends DOWN notification
  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    {:ok, channel} = get_channel(state.queue)

    {:noreply, %State{state|channel: channel}}
  end

  # Helpers

  defp get_channel(queue) do
    case AtlasAmqp.Connection.open_channel() do
      {:ok, channel} ->
        # Limit unacknowledged messages to 10
        :ok = Basic.qos(channel, prefetch_count: 10)
        # Register the GenServer process as a consumer
        {:ok, _consumer_tag} = Basic.consume(channel, queue)
        {:ok, channel}
      {:error, _} ->
        :timer.sleep(@reconnect_interval)
        get_channel(queue)
    end
  end

  defp consume(channel, tag, redelivered, payload) do
    number = String.to_integer(payload)
    if number <= 10 do
      :ok = Basic.ack channel, tag
      IO.puts "Consumed a #{number}."
    else
      :ok = Basic.reject channel, tag, requeue: false
      IO.puts "#{number} is too big and was rejected."
    end
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise comsumer will stop
    # receiving messages.
    _exception ->
      :ok = Basic.reject channel, tag, requeue: not redelivered
      IO.puts "Error converting #{payload} to integer"
  end
end
