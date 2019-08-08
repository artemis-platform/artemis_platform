defmodule ArtemisWeb.UserAnonymizationController do
  use ArtemisWeb, :controller

  alias Artemis.AnonymizeUser
  alias Artemis.GetUser

  def create(conn, %{"user_id" => id}) do
    authorize(conn, "user-anonymizations:create", fn ->
      user = current_user(conn)
      record = GetUser.call!(id, user)

      case user.id == record.id do
        false ->
          case AnonymizeUser.call(id, user) do
            {:ok, _} ->
              conn
              |> put_flash(:info, "User anonymized successfully.")
              |> redirect(to: Routes.user_path(conn, :show, record))

            {:error, _} ->
              conn
              |> put_flash(:error, "Error anonymizing user")
              |> redirect(to: Routes.user_path(conn, :show, record))
          end

        true ->
          conn
          |> put_flash(:error, "Cannot anonymize own user")
          |> redirect(to: Routes.user_path(conn, :show, record))
      end
    end)
  end
end
