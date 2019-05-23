defmodule ArtemisPubSub do
  @server ArtemisPubSub

  def subscribe(topic) when is_binary(topic) do
    Phoenix.PubSub.subscribe(@server, topic, [])
  end

  def subscribe(topic, opts) when is_binary(topic) and is_list(opts) do
    Phoenix.PubSub.subscribe(@server, topic, opts)
  end

  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(@server, topic)
  end

  def broadcast_from(from, topic, event, msg) do
    Phoenix.Channel.Server.broadcast_from(@server, from, topic, event, msg)
  end

  def broadcast_from!(from, topic, event, msg) do
    Phoenix.Channel.Server.broadcast_from!(@server, from, topic, event, msg)
  end

  def broadcast(topic, event, msg) do
    Phoenix.Channel.Server.broadcast(@server, topic, event, msg)
  end

  def broadcast!(topic, event, msg) do
    Phoenix.Channel.Server.broadcast!(@server, topic, event, msg)
  end

  def direct_broadcast(topic, msg) do
    Phoenix.PubSub.direct_broadcast(node(), @server, topic, msg)
  end

  def direct_broadcast!(topic, msg) do
    Phoenix.PubSub.direct_broadcast!(node(), @server, topic, msg)
  end
end
