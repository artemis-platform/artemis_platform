defmodule AtlasWeb.EventLogController do
  use AtlasWeb, :controller

  alias AtlasLog.GetEventLog
  alias AtlasLog.ListEventLogs

  def index(conn, params) do
    authorize(conn, "event-logs:list", fn () ->
      event_logs = ListEventLogs.call(params)

      render(conn, "index.html", event_logs: event_logs)
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "event-logs:show", fn () ->
      event_log = GetEventLog.call!(id)

      render(conn, "show.html", event_log: event_log)
    end)
  end
end
