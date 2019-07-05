defmodule ArtemisWeb.ViewHelper.Notifications do
  use Phoenix.HTML

  @doc """
  Generates a notification
  """
  def render_notification(type, params \\ []) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "notification_#{type}.html", params)
  end

  @doc """
  Generates flash notifications
  """
  def render_flash_notifications(conn) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "flash_notifications.html", conn: conn)
  end
end
