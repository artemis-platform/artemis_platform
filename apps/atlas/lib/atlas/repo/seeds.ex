defmodule Atlas.Repo.Seeds do
  import Ecto.Query

  alias Atlas.Permission
  alias Atlas.Repo
  alias Atlas.Role
  alias Atlas.User
  alias Atlas.UserRole

  def call() do

    # Roles

    roles = [
      %{slug: "developer", name: "Site Developer"},
    ]

    Enum.map(roles, fn (params) ->
      case Repo.get_by(Role, slug: params.slug) do
        nil ->
          %Role{}
          |> Role.changeset(params)
          |> Repo.insert!
        _ ->
          :ok
      end
    end)

    # Permissions

    permissions = [
      %{slug: "event-logs:access:all", name: "Event Logs - Access All"},
      %{slug: "event-logs:access:self", name: "Event Logs - Access Self"},
      %{slug: "event-logs:list", name: "Event Logs - List"},
      %{slug: "event-logs:show", name: "Event Logs - Show"},

      %{slug: "features:create", name: "Features - Create"},
      %{slug: "features:delete", name: "Features - Delete"},
      %{slug: "features:list", name: "Features - List"},
      %{slug: "features:show", name: "Features - Show"},
      %{slug: "features:update", name: "Features - Update"},

      %{slug: "permissions:create", name: "Permissions - Create"},
      %{slug: "permissions:delete", name: "Permissions - Delete"},
      %{slug: "permissions:list", name: "Permissions - List"},
      %{slug: "permissions:show", name: "Permissions - Show"},
      %{slug: "permissions:update", name: "Permissions - Update"},

      %{slug: "roles:create", name: "Roles - Create"},
      %{slug: "roles:delete", name: "Roles - Delete"},
      %{slug: "roles:list", name: "Roles - List"},
      %{slug: "roles:show", name: "Roles - Show"},
      %{slug: "roles:update", name: "Roles - Update"},

      %{slug: "user-impersonations:create", name: "User Impersonations - Create"},

      %{slug: "users:access:all", name: "Users - Access All"},
      %{slug: "users:access:self", name: "Users - Access Self"},
      %{slug: "users:create", name: "Users - Create"},
      %{slug: "users:delete", name: "Users - Delete"},
      %{slug: "users:list", name: "Users - List"},
      %{slug: "users:show", name: "Users - Show"},
      %{slug: "users:update", name: "Users - Update"}
    ]

    Enum.map(permissions, fn (params) ->
      case Repo.get_by(Permission, slug: params.slug) do
        nil ->
          %Permission{}
          |> Permission.changeset(params)
          |> Repo.insert!
        _ ->
          :ok
      end
    end)

    # Role Permissions - Developer Role

    permissions = Repo.all(Permission)

    role = Role
      |> preload([:permissions, :user_roles])
      |> Repo.get_by(slug: "developer")

    role
    |> Role.associations_changeset(%{permissions: permissions})
    |> Repo.update!

    # Users

    users = [
      Application.fetch_env!(:atlas, :root_user),
      Application.fetch_env!(:atlas, :system_user)
    ]

    Enum.map(users, fn (params) ->
      case Repo.get_by(User, email: params.email) do
        nil ->
          params = params
            |> Map.put(:client_key, Atlas.Helpers.random_string(30))
            |> Map.put(:client_secret, Atlas.Helpers.random_string(100))

          %User{}
          |> User.changeset(params)
          |> Repo.insert!
        _ ->
          :ok
      end
    end)

    # User Roles

    role = Repo.get_by!(Role, slug: "developer")

    user_emails = [
      Application.fetch_env!(:atlas, :root_user).email,
      Application.fetch_env!(:atlas, :system_user).email
    ]
    users = Enum.map(user_emails, &Repo.get_by!(User, email: &1))

    Enum.map(users, fn(user) ->
      case Repo.get_by(UserRole, role_id: role.id, user_id: user.id) do
        nil ->
          params = %{
            created_by_id: user.id,
            role_id: role.id,
            user_id: user.id
          }

          %UserRole{}
          |> UserRole.changeset(params)
          |> Repo.insert!
        _ ->
          :ok
      end
    end)
  end
end
