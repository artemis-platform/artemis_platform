defmodule Artemis.CacheEvent do
  @moduledoc """
  Broadcast cache events
  """

  defmodule Data do
    defstruct [
      :meta,
      :module,
      :type
    ]
  end

  @broadcast_topic "private:artemis:cache-events"

  def get_broadcast_topic, do: @broadcast_topic

  def broadcast(event, module, meta \\ %{})

  def broadcast(event, module, meta) do
    payload = %Data{
      meta: meta,
      module: module,
      type: "cache-event"
    }

    ArtemisPubSub.broadcast(@broadcast_topic, event, payload)
  end
end
