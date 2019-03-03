defmodule ArtemisApi.UsersTest do
  use ArtemisApi.ConnCase, async: true
  use Plug.Test

  describe "authentication" do
    test "returns 401 when user is not authenticated", %{conn: conn} do
      query = """
        query listUsers{
          listUsers{
            id
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

  describe "authorization" do
    test "supports two-step bearer token flows", %{conn: conn} do
      query = """
        query listUsers{
          listUsers{
            entries {
              id
            }
          }
        }
      """

      conn = sign_in(conn)
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "supports one-step client credentials flow", %{conn: conn} do
      query = """
        query listUsers{
          listUsers{
            entries {
              id
            }
          }
        }
      """

      conn = sign_in_with_client_credentials(conn)
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end
  end

  describe "index" do
    setup %{conn: conn} do
      query = """
        query listUsers{
          listUsers{
            entries {
              id
            }
            page_number
            page_size
            total_entries
            total_pages
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

    test "returns paginated data", %{conn: conn, query: query} do
      user = Mock.system_user()
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("listUsers")

      entry_ids = payload
        |> Map.get("entries")
        |> Enum.map(&Map.get(&1, "id"))

      assert Enum.member?(entry_ids, "#{user.id}")
      assert payload["page_number"] == 1
      assert payload["page_size"] == 25
      assert payload["total_entries"] > 0
      assert payload["total_pages"] == 1
    end
  end

  describe "show" do
    setup %{conn: conn} do
      user = Mock.system_user()
      query = """
        query getUser{
          getUser(
            id: "#{user.id}"
          ){
            id
            email
            first_name
            last_name
            name
            inserted_at
            updated_at
            permissions {
              id
            }
            roles {
              id
            }
          }
        }
      """

      conn = sign_in(conn)

      {:ok, conn: conn, query: query, user: user}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns user attributes", %{conn: conn, query: query, user: user} do
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("getUser")

      assert payload["id"] == "#{user.id}"
      assert payload["email"] == user.email
      assert payload["first_name"] == user.first_name
      assert payload["last_name"] == user.last_name
      assert payload["name"] == user.name
      assert payload["inserted_at"] != nil
      assert payload["updated_at"] != nil
    end

    test "returns user associations", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("getUser")

      assert length(payload["permissions"]) > 0
      assert length(payload["roles"]) > 0
    end
  end

  describe "create" do
    setup %{conn: conn} do
      query = """
        mutation createUser{
          createUser(
            user: {
              email: "user@test.com",
              name: "Test User"
            }
          ){
            id
            email
            name
            inserted_at
            updated_at
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

    test "returns user attributes", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("createUser")

      assert payload["email"] == "user@test.com"
      assert payload["name"] == "Test User"
    end
  end

  describe "update" do
    setup %{conn: conn} do
      user = Mock.system_user()
      query = """
        mutation updateUser{
          updateUser(
            id: "#{user.id}",
            user: {
              email: "updated@test.com",
              name: "Updated User"
            }
          ){
            id
            email
            name
            inserted_at
            updated_at
          }
        }
      """

      conn = sign_in(conn)

      {:ok, conn: conn, query: query, user: user}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns user attributes", %{conn: conn, query: query, user: user} do
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("updateUser")

      assert payload["id"] == "#{user.id}"
      assert payload["email"] == "updated@test.com"
      assert payload["name"] == "Updated User"
    end
  end

  describe "delete" do
    setup %{conn: conn} do
      user = Mock.system_user()
      query = """
        mutation deleteUser{
          deleteUser(
            id: "#{user.id}"
          ){
            id
            email
            name
            inserted_at
            updated_at
          }
        }
      """

      conn = sign_in(conn)

      {:ok, conn: conn, query: query, user: user}
    end

    test "returns 200 when sent valid request", %{conn: conn, query: query} do
      conn = post(conn, "/data", %{query: query})

      assert conn.state == :sent
      assert conn.status == 200
    end

    test "returns user attributes", %{conn: conn, query: query, user: user} do
      conn = post(conn, "/data", %{query: query})

      payload = conn.resp_body
        |> Jason.decode!()
        |> Map.get("data")
        |> Map.get("deleteUser")

      assert payload["id"] == "#{user.id}"
    end
  end
end
