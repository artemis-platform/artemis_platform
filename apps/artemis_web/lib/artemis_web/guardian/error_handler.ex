defmodule ArtemisWeb.Guardian.ErrorHandler do
  import ArtemisWeb.Guardian.Helpers

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    case current_user?(conn) do
      true -> render_unauthorized(conn)
      false -> redirect_to_log_in(conn)
    end
  end
end
