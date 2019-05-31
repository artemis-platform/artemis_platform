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
    payload = %{
      endpoint: "web",
      node: Atom.to_string(node()),
      path: conn.request_path,
      query_string: conn.query_string,
      session_id: get_session_id(conn)
    }

    HttpRequest.broadcast(payload, current_user(conn))

    conn
  end

  # Uses the `verify signature` section of the JWT token as a pseudo session
  # identifier. It is not guaranteed to be unique.
  #
  # Can be used to analyze the http requests a specific user made during a
  # single session / log in without having to guess on log in boundaries based
  # on timestamps.
  defp get_session_id(conn) do
    conn
    |> Guardian.Plug.current_token()
    |> String.split(".")
    |> Enum.at(2)
    |> String.slice(0..10)
  end
end
