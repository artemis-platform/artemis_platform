defmodule ArtemisWeb.UserController do
  use ArtemisWeb, :controller

  alias Artemis.CreateUser
  alias Artemis.User
  alias Artemis.DeleteUser
  alias Artemis.GetUser
  alias Artemis.ListRoles
  alias Artemis.ListUsers
  alias Artemis.UpdateUser

  @preload [:user_roles]

  def index(conn, params) do
    authorize(conn, "users:list", fn () ->
      params = Map.put(params, :paginate, true)
      users = ListUsers.call(params)

      render(conn, "index.html", users: users)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "users:create", fn () ->
      user = %User{user_roles: []}
      changeset = User.changeset(user)
      roles = ListRoles.call()

      render(conn, "new.html", changeset: changeset, roles: roles, user: user)
    end)
  end

  def create(conn, %{"user" => params}) do
    authorize(conn, "users:create", fn () ->
      params = checkbox_to_params(params, "user_roles")

      case CreateUser.call(params, current_user(conn)) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User created successfully.")
          |> redirect(to: Routes.user_path(conn, :show, user))

        {:error, %Ecto.Changeset{} = changeset} ->
          user = %User{user_roles: []}
          roles = ListRoles.call()

          render(conn, "new.html", changeset: changeset, roles: roles, user: user)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "users:show", fn () ->
      user = GetUser.call!(id, current_user(conn))

      render(conn, "show.html", user: user)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "users:update", fn () ->
      user = GetUser.call(id, current_user(conn), preload: @preload)
      changeset = User.changeset(user)
      roles = ListRoles.call()

      render(conn, "edit.html", changeset: changeset, roles: roles, user: user)
    end)
  end

  def update(conn, %{"id" => id, "user" => params}) do
    authorize(conn, "users:update", fn () ->
      params = checkbox_to_params(params, "user_roles")

      case UpdateUser.call(id, params, current_user(conn)) do
        {:ok, user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: Routes.user_path(conn, :show, user))

        {:error, %Ecto.Changeset{} = changeset} ->
          user = GetUser.call(id, current_user(conn), preload: @preload)
          roles = ListRoles.call()

          render(conn, "edit.html", changeset: changeset, roles: roles, user: user)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "users:delete", fn () ->
      {:ok, _user} = DeleteUser.call(id, current_user(conn))

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: Routes.user_path(conn, :index))
    end)
  end
end
