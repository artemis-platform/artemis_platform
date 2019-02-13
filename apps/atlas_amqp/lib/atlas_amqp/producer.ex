defmodule AtlasAmqp.Producer do
  @default_exchange "atlas_exchange"
  @default_queue "atlas_queue"

  def publish(message, options \\ []) do
    {:ok, channel} = AtlasAmqp.Connection.open_channel()

    exchange = Keyword.get(options, :exchange, @default_exchange)
    queue = Keyword.get(options, :queue, @default_queue)

    :ok = AMQP.Basic.publish(channel, exchange, queue, message)

    AtlasAmqp.Connection.close_channel(channel)
  end
end
