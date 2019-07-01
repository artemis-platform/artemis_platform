defmodule ArtemisWeb.Plug.BroadcastRequest do
  @moduledoc """
  Broadcast http requests made by authenticated users
  """

  @behaviour Plug

  import ArtemisWeb.Guardian.Helpers

  alias Artemis.HttpRequest

  def init(opts), do: opts

  def call(conn, _) do
    case current_user?(conn) do
      true -> broadcast_request(conn)
      false -> conn
    end
  end

  defp broadcast_request(conn) do
    user = current_user(conn)

    payload = %{
      endpoint: "web",
      node: Atom.to_string(node()),
      path: conn.request_path,
      query_string: conn.query_string
    }

    HttpRequest.broadcast(payload, user)

    conn
  end
end
