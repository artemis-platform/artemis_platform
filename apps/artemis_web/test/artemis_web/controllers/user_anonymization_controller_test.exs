defmodule ArtemisWeb.UserAnonymizationControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "create" do
    test "anonymizes user and redirects to show when data is valid", %{conn: conn} do
      record = insert(:user)

      conn = post(conn, Routes.user_anonymization_path(conn, :create, record))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Anonymized User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      system_user = Mock.system_user()

      conn = post(conn, Routes.user_anonymization_path(conn, :create, system_user))
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      refute html_response(conn, 200) =~ "Anonymized User"
    end
  end
end
