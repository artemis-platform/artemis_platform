defmodule ArtemisWeb.Guardian.Helpers do
  import Plug.Conn

  alias ArtemisWeb.ErrorView

  @doc """
  Returns the logged in user
  """
  def current_user(conn) do
    ArtemisWeb.Guardian.Plug.current_resource(conn)
  end

  @doc """
  Returns boolean if user is logged in
  """
  def current_user?(conn) do
    case ArtemisWeb.Guardian.Plug.current_resource(conn) do
      nil -> false
      _ -> true
    end
  end

  @doc """
  Immediately return a 401 unauthorized page
  """
  def render_unauthorized(conn) do
    conn
    |> put_status(401)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("401.html", error_page: true)
  end

  @doc """
  Immediately return a 403 unauthorized page
  """
  def render_forbidden(conn) do
    conn
    |> put_status(403)
    |> Phoenix.Controller.put_view(ErrorView)
    |> Phoenix.Controller.render("403.html", error_page: true)
  end

  @doc """
  Immediately redirect to the user log in
  """
  def redirect_to_log_in(conn) do
    path = ArtemisWeb.Router.Helpers.session_path(conn, :new)
    query_params = "?redirect=#{conn.request_path}"

    conn
    |> ArtemisWeb.Guardian.Plug.sign_out()
    |> Phoenix.Controller.put_flash(:info, "Log in to continue")
    |> Phoenix.Controller.redirect(to: path <> query_params)
  end
end
