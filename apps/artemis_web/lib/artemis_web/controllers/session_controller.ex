defmodule ArtemisWeb.SessionController do
  require Logger

  use ArtemisWeb, :controller

  import ArtemisWeb.Guardian.Plug

  alias Artemis.Event
  alias ArtemisWeb.CreateSession
  alias ArtemisWeb.GetUserByAuthProvider
  alias ArtemisWeb.ListSessionAuthProviders

  def new(conn, _params) do
    render(conn, "new.html", providers: ListSessionAuthProviders.call(conn))
  end

  def show(conn, params) do
    with {:ok, user} <- GetUserByAuthProvider.call(params),
         {:ok, session} <- CreateSession.call(user),
         {:ok, _} <- Event.broadcast(session, "session:created:web", user) do
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
    conn
    |> sign_out()
    |> put_flash(:info, "Successfully logged out")
    |> redirect(to: "/")
  end
end
