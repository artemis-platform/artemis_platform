defmodule Artemis.HttpRequest do
  @moduledoc """
  Broadcast page requests by authenticated users
  """

  @broadcast_topic "private:artemis:http-requests"

  def get_broadcast_topic, do: @broadcast_topic

  def broadcast({:ok, data} = result, user) do
    payload = %{
      data: data,
      user: user
    }

    :ok = ArtemisPubSub.broadcast(@broadcast_topic, "http-request", payload)

    result
  end

  def broadcast({:error, _} = result, _user) do
    result
  end

  def broadcast(data, user) do
    broadcast({:ok, data}, user)
  end
end
