defmodule Artemis.Event do
  @moduledoc """
  Broadcast events that change data
  """

  @broadcast_topic "private:artemis:events"

  def get_broadcast_topic, do: @broadcast_topic

  def broadcast(result, event, meta \\ %{}, user)

  def broadcast({:ok, data} = result, event, meta, user) do
    payload = %{
      data: data,
      meta: meta,
      user: user
    }

    :ok = ArtemisPubSub.broadcast(@broadcast_topic, event, payload)

    result
  end

  def broadcast({:error, _} = result, _event, _meta, _user) do
    result
  end

  def broadcast(data, event, meta, user) do
    broadcast({:ok, data}, event, meta, user)
  end
end
