defmodule AtlasWeb.SessionController do
  require Logger

  use AtlasWeb, :controller

  import AtlasWeb.Guardian.Plug

  alias Atlas.CreateAuditLog
  alias AtlasWeb.CreateSession
  alias AtlasWeb.DeleteSession
  alias AtlasWeb.GetUserByAuthProvider
  alias AtlasWeb.ListSessionAuthProviders

  def new(conn, _params) do
    render(conn, "new.html", providers: ListSessionAuthProviders.call(conn))
  end

  def show(conn, params) do
    with {:ok, user} <- GetUserByAuthProvider.call(params),
         {:ok, session} <- CreateSession.call(user),
         {:ok, _} <- CreateAuditLog.call(action: "User Logged In", user: user) do
      Logger.debug "Log In With Provider Session: " <> inspect(session)

      conn
      |> sign_in(user)
      |> put_flash(:info, "Successfully logged in")
      |> redirect(to: "/")
    else
      error ->
        Logger.debug "Log In With Provider Error: " <> inspect(error)
        render(conn, "new.html", providers: ListSessionAuthProviders.call(conn))
    end
  end

  def delete(conn, _params) do
    {:ok, _} = DeleteSession.call()

    conn
    |> sign_out()
    |> put_flash(:info, "Successfully logged out")
    |> redirect(to: "/")
  end
end
