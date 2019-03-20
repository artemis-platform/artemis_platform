defmodule ArtemisWeb.PermissionControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{name: "some name", slug: "test-slug"}
  @update_attrs %{name: "some updated name", slug: "test-slug"}
  @invalid_attrs %{name: nil, slug: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all permissions", %{conn: conn} do
      conn = get(conn, Routes.permission_path(conn, :index))
      assert html_response(conn, 200) =~ "Permissions"
    end
  end

  describe "new permission" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.permission_path(conn, :new))
      assert html_response(conn, 200) =~ "New Permission"
    end
  end

  describe "create permission" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.permission_path(conn, :create), permission: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.permission_path(conn, :show, id)

      conn = get(conn, Routes.permission_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.permission_path(conn, :create), permission: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Permission"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows permission", %{conn: conn, record: record} do
      conn = get(conn, Routes.permission_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit permission" do
    setup [:create_record]

    test "renders form for editing chosen permission", %{conn: conn, record: record} do
      conn = get(conn, Routes.permission_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Permission"
    end
  end

  describe "update permission" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.permission_path(conn, :update, record), permission: @update_attrs)
      assert redirected_to(conn) == Routes.permission_path(conn, :show, record)

      conn = get(conn, Routes.permission_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.permission_path(conn, :update, record), permission: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Permission"
    end
  end

  describe "delete permission" do
    setup [:create_record]

    test "deletes chosen permission", %{conn: conn, record: record} do
      conn = delete(conn, Routes.permission_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.permission_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.permission_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:permission)

    {:ok, record: record}
  end
end
