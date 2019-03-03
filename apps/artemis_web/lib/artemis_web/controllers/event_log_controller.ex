defmodule ArtemisWeb.EventLogController do
  use ArtemisWeb, :controller

  alias ArtemisLog.GetEventLog
  alias ArtemisLog.ListEventLogs

  def index(conn, params) do
    authorize(conn, "event-logs:list", fn () ->
      event_logs = ListEventLogs.call(params)

      render(conn, "index.html", event_logs: event_logs)
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "event-logs:show", fn () ->
      event_log = GetEventLog.call!(id, current_user(conn))

      render(conn, "show.html", event_log: event_log)
    end)
  end
end
