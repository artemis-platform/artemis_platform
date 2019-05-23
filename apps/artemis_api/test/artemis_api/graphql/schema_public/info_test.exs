defmodule ArtemisApi.InfoTest do
  use ArtemisApi.ConnCase, async: true
  use Plug.Test

  describe "info" do
    setup do
      query = """
        query info{
          info{
            release_branch
            release_hash
            release_version
          }
        }
      """

      {:ok, query: query}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns a payload", %{conn: conn, query: query} do
      conn = post(conn, "/", %{query: query})

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
