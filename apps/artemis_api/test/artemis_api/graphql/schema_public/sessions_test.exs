defmodule ArtemisApi.Public.SessionsTest do
  use ArtemisApi.ConnCase, async: true
  use Plug.Test

  describe "create_session" do
    setup do
      user = Mock.system_user()

      query = """
        mutation createSession{
          createSession(
            clientKey: "#{user.client_key}",
            clientSecret:"#{user.client_secret}",
            provider:"client-credentials"
          ){
            token
            token_creation
            token_expiration
            user {
              id
            }
          }
        }
      """

      {:ok, query: query, user: user}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns a token", %{conn: conn, query: query} do
      conn = post(conn, "/", %{query: query})

      payload =
        conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("createSession")

      assert payload["token"] != nil
    end

    test "returns a token expiration time", %{conn: conn, query: query} do
      conn = post(conn, "/", %{query: query})

      payload =
        conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("createSession")

      assert payload["token_creation"] != nil
      assert payload["token_expiration"] != nil

      expires_in = String.to_integer(payload["token_expiration"]) - String.to_integer(payload["token_creation"])

      assert expires_in == 60 * 60 * 18
    end

    test "returns a user", %{conn: conn, query: query, user: user} do
      conn = post(conn, "/", %{query: query})

      payload =
        conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("createSession")

      assert payload["user"]["id"] == "#{user.id}"
    end

    test "broadcasts an event", %{conn: conn, query: query} do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      post(conn, "/", %{query: query})

      assert_received %Phoenix.Socket.Broadcast{
        event: "session:created:api"
      }
    end
  end
end
