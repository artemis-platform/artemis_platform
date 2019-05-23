defmodule ArtemisApi.Public.InfoTest do
  use ArtemisApi.ConnCase, async: true
  use Plug.Test

  describe "authentication" do
    test "returns 401 when user is not authenticated", %{conn: conn} do
      query = """
        query info{
          info{
            release_branch
            release_hash
            release_version
          }
        }
      """

      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 401

      payload = Jason.decode!(conn.resp_body)

      assert payload["message"] == "unauthenticated"
    end
  end

  describe "info" do
    setup %{conn: conn} do
      query = """
        query info{
          info{
            release_branch
            release_hash
            release_version
          }
        }
      """

      conn = sign_in(conn)

      {:ok, conn: conn, query: query}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns a payload", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      payload =
        conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("info")

      assert payload["release_branch"] != nil
      assert payload["release_hash"] != nil
      assert payload["release_version"] != nil
    end
  end
end
