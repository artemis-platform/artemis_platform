defmodule ArtemisWeb.EventLogControllerTest do
  use ArtemisWeb.ConnCase

  import ArtemisLog.Factories

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all event logs", %{conn: conn} do
      conn = get(conn, Routes.event_log_path(conn, :index))
      assert html_response(conn, 200) =~ "Event Logs"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event logs", %{conn: conn, record: record} do
      conn = get(conn, Routes.event_log_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Name"
    end
  end

  defp create_record(_) do
    record = insert(:event_log)

    {:ok, record: record}
  end
end
