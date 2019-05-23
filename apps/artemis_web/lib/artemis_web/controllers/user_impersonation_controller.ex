defmodule ArtemisWeb.UserImpersonationController do
  use ArtemisWeb, :controller

  import ArtemisWeb.Guardian.Plug

  alias Artemis.Event
  alias Artemis.GetUser
  alias ArtemisWeb.CreateSession

  def create(conn, %{"user_id" => id}) do
    authorize(conn, "user-impersonations:create", fn ->
      user = GetUser.call!(id, current_user(conn))

      with {:ok, _} <- CreateSession.call(user),
           {:ok, _} <- Event.broadcast(user, "user-impersonation:created", current_user(conn)) do
        conn
        |> sign_in(user)
        |> put_flash(:info, "User impersonation created")
        |> redirect(to: "/")
      else
        {:error, _} ->
          conn
          |> put_flash(:error, "Error creating user impersonation")
          |> redirect(to: Routes.user_path(conn, :show, user))
      end
    end)
  end
end
