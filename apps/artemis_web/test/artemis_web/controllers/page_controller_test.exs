defmodule ArtemisWeb.PageControllerTest do
  use ArtemisWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Artemis"
  end
end
