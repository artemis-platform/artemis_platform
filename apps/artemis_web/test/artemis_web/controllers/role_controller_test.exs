defmodule ArtemisWeb.RoleControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{name: "some name", slug: "test-slug"}
  @update_attrs %{name: "some updated name", slug: "test-slug"}
  @invalid_attrs %{name: nil, slug: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all roles", %{conn: conn} do
      conn = get(conn, Routes.role_path(conn, :index))
      assert html_response(conn, 200) =~ "Roles"
    end
  end

  describe "new role" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.role_path(conn, :new))
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "create role" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.role_path(conn, :create), role: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.role_path(conn, :show, id)

      conn = get(conn, Routes.role_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.role_path(conn, :create), role: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Role"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows role", %{conn: conn, record: record} do
      conn = get(conn, Routes.role_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit role" do
    setup [:create_record]

    test "renders form for editing chosen role", %{conn: conn, record: record} do
      conn = get(conn, Routes.role_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "update role" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.role_path(conn, :update, record), role: @update_attrs)
      assert redirected_to(conn) == Routes.role_path(conn, :show, record)

      conn = get(conn, Routes.role_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.role_path(conn, :update, record), role: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Role"
    end
  end

  describe "delete role" do
    setup [:create_record]

    test "deletes chosen role", %{conn: conn, record: record} do
      conn = delete(conn, Routes.role_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.role_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.role_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:role)

    {:ok, record: record}
  end
end
