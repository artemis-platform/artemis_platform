defmodule ArtemisWeb.FeatureControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @create_attrs %{name: "some name", slug: "test-slug"}
  @update_attrs %{name: "some updated name", slug: "test-slug"}
  @invalid_attrs %{name: nil, slug: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all features", %{conn: conn} do
      conn = get(conn, Routes.feature_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Features"
    end
  end

  describe "new feature" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.feature_path(conn, :new))
      assert html_response(conn, 200) =~ "New Feature"
    end
  end

  describe "create feature" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.feature_path(conn, :show, id)

      conn = get(conn, Routes.feature_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.feature_path(conn, :create), feature: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Feature"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows feature", %{conn: conn, record: record} do
      conn = get(conn, Routes.feature_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  describe "edit feature" do
    setup [:create_record]

    test "renders form for editing chosen feature", %{conn: conn, record: record} do
      conn = get(conn, Routes.feature_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Feature"
    end
  end

  describe "update feature" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.feature_path(conn, :update, record), feature: @update_attrs)
      assert redirected_to(conn) == Routes.feature_path(conn, :show, record)

      conn = get(conn, Routes.feature_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.feature_path(conn, :update, record), feature: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Feature"
    end
  end

  describe "delete feature" do
    setup [:create_record]

    test "deletes chosen feature", %{conn: conn, record: record} do
      conn = delete(conn, Routes.feature_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.feature_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.feature_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:feature)

    {:ok, record: record}
  end
end
