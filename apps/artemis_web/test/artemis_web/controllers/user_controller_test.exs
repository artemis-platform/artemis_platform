defmodule ArtemisWeb.UserControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{email: "some@email", name: "some name"}
  @update_attrs %{email: "some_updated@email", name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows user", %{conn: conn, record: record} do
      conn = get(conn, Routes.user_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit user" do
    setup [:create_record]

    test "renders form for editing chosen user", %{conn: conn, record: record} do
      conn = get(conn, Routes.user_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.user_path(conn, :update, record), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, record)

      conn = get(conn, Routes.user_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.user_path(conn, :update, record), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_record]

    test "deletes chosen user", %{conn: conn, record: record} do
      conn = delete(conn, Routes.user_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.user_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:user)

    {:ok, record: record}
  end
end
