defmodule ArtemisWeb.PermissionController do
  use ArtemisWeb, :controller

  alias Artemis.CreatePermission
  alias Artemis.Permission
  alias Artemis.DeletePermission
  alias Artemis.GetPermission
  alias Artemis.ListPermissions
  alias Artemis.UpdatePermission

  @preload []

  def index(conn, params) do
    authorize(conn, "permissions:list", fn () ->
      params = Map.put(params, :paginate, true)
      permissions = ListPermissions.call(params)

      render(conn, "index.html", permissions: permissions)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "permissions:create", fn () ->
      permission = %Permission{}
      changeset = Permission.changeset(permission)

      render(conn, "new.html", changeset: changeset, permission: permission)
    end)
  end

  def create(conn, %{"permission" => params}) do
    authorize(conn, "permissions:create", fn () ->
      case CreatePermission.call(params, current_user(conn)) do
        {:ok, permission} ->
          conn
          |> put_flash(:info, "Permission created successfully.")
          |> redirect(to: Routes.permission_path(conn, :show, permission))

        {:error, %Ecto.Changeset{} = changeset} ->
          permission = %Permission{}

          render(conn, "new.html", changeset: changeset, permission: permission)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "permissions:show", fn () ->
      permission = GetPermission.call!(id)

      render(conn, "show.html", permission: permission)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "permissions:update", fn () ->
      permission = GetPermission.call(id, preload: @preload)
      changeset = Permission.changeset(permission)

      render(conn, "edit.html", changeset: changeset, permission: permission)
    end)
  end

  def update(conn, %{"id" => id, "permission" => params}) do
    authorize(conn, "permissions:update", fn () ->
      case UpdatePermission.call(id, params, current_user(conn)) do
        {:ok, permission} ->
          conn
          |> put_flash(:info, "Permission updated successfully.")
          |> redirect(to: Routes.permission_path(conn, :show, permission))

        {:error, %Ecto.Changeset{} = changeset} ->
          permission = GetPermission.call(id, preload: @preload)

          render(conn, "edit.html", changeset: changeset, permission: permission)
      end
    end)
  end

  def delete(conn, %{"id" => id}) do
    authorize(conn, "permissions:delete", fn () ->
      {:ok, _permission} = DeletePermission.call(id, current_user(conn))

      conn
      |> put_flash(:info, "Permission deleted successfully.")
      |> redirect(to: Routes.permission_path(conn, :index))
    end)
  end
end
