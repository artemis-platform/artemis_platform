defmodule ArtemisWeb.RoleController do
  use ArtemisWeb, :controller

  alias Artemis.CreateRole
  alias Artemis.Role
  alias Artemis.DeleteRole
  alias Artemis.GetRole
  alias Artemis.ListPermissions
  alias Artemis.ListRoles
  alias Artemis.UpdateRole

  @preload [:permissions]

  def index(conn, params) do
    authorize(conn, "roles:list", fn () ->
      params = Map.put(params, :paginate, true)
      roles = ListRoles.call(params)

      render(conn, "index.html", roles: roles)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "roles:create", fn () ->
      role = %Role{permissions: []}
      changeset = Role.changeset(role)
      permissions = ListPermissions.call()

      render(conn, "new.html", changeset: changeset, permissions: permissions, role: role)
    end)
  end

  def create(conn, %{"role" => params}) do
    authorize(conn, "roles:create", fn () ->
      params = Map.put_new(params, "permissions", [])

      case CreateRole.call(params, current_user(conn)) do
        {:ok, role} ->
          conn
          |> put_flash(:info, "Role created successfully.")
          |> redirect(to: Routes.role_path(conn, :show, role))

        {:error, %Ecto.Changeset{} = changeset} ->
          role = %Role{permissions: []}
          permissions = ListPermissions.call()

          render(conn, "new.html", changeset: changeset, permissions: permissions, role: role)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "roles:show", fn () ->
      role = GetRole.call!(id)

      render(conn, "show.html", role: role)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "roles:update", fn () ->
      role = GetRole.call(id, preload: @preload)
      changeset = Role.changeset(role)
      permissions = ListPermissions.call()

      render(conn, "edit.html", changeset: changeset, permissions: permissions, role: role)
    end)
  end

  def update(conn, %{"id" => id, "role" => params}) do
    authorize(conn, "roles:update", fn () ->
      params = Map.put_new(params, "permissions", [])

      case UpdateRole.call(id, params, current_user(conn)) do
        {:ok, role} ->
          conn
          |> put_flash(:info, "Role updated successfully.")
          |> redirect(to: Routes.role_path(conn, :show, role))

        {:error, %Ecto.Changeset{} = changeset} ->
          role = GetRole.call(id, preload: @preload)
          permissions = ListPermissions.call()

          render(conn, "edit.html", changeset: changeset, permissions: permissions, role: role)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "roles:delete", fn () ->
      {:ok, _role} = DeleteRole.call(id, current_user(conn))

      conn
      |> put_flash(:info, "Role deleted successfully.")
      |> redirect(to: Routes.role_path(conn, :index))
    end)
  end
end
