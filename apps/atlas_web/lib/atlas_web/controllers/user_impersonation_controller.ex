defmodule AtlasWeb.UserImpersonationController do
  use AtlasWeb, :controller

  import AtlasWeb.Guardian.Plug

  alias Atlas.CreateAuditLog
  alias Atlas.CreateSession
  alias Atlas.GetUser

  def create(conn, %{"user_id" => id}) do
    authorize(conn, "user-impersonations:create", fn () ->
      current_user = current_user(conn)
      user = GetUser.call!(id)

      with {:ok, _} <- CreateSession.call(user),
           {:ok, _} <- CreateAuditLog.call(action: "User Impersonation Created", user: current_user) do
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
