defmodule ArtemisWeb.AuthController do
  use ArtemisWeb, :controller

  plug Ueberauth

  require Logger

  import ArtemisWeb.Guardian.Plug

  alias Artemis.Event
  alias ArtemisWeb.CreateSession
  alias ArtemisWeb.GetUserByAuthProviderData

  @moduledoc """
  Responsible for handling user authentication
  """

  def new(conn, _params) do
    case current_user(conn) do
      nil ->
        render(conn, "new.html")
      _user ->
        conn
        |> put_flash(:info, "Already logged in")
        |> redirect(to: "/")
    end
  end

  def request(conn, _params) do
    conn
    |> put_flash(:info, "Specified Auth Provider not recognized")
    |> redirect(to: Routes.auth_path(conn, :new))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end
  def callback(%{assigns: %{ueberauth_auth: data}} = conn, _params) do
    with {:ok, user} <- GetUserByAuthProviderData.call(data),
         {:ok, session} <- CreateSession.call(user),
         {:ok, _} <- Event.broadcast(session, "session:created:web", user) do
      Logger.debug "Log In with Auth Provider Session: " <> inspect(session)

      conn
      |> sign_in(user)
      |> put_flash(:info, "Successfully logged in")
      |> redirect(to: "/")
    else
      error ->
        Logger.debug "Log In With Provider Error: " <> inspect(error)

        conn
        |> put_flash(:error, "Error logging in")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> sign_out()
    |> put_flash(:info, "Successfully logged out")
    |> redirect(to: "/")
  end
end
