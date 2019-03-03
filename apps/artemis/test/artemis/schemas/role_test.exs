defmodule Artemis.RoleTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Permission
  alias Artemis.Repo
  alias Artemis.Role
  alias Artemis.UserRole

  @preload [:permissions, :user_roles]

  describe "attributes - constraints" do
    test "name must be unique" do
      existing = insert(:role)

      assert_raise Ecto.ConstraintError, fn () ->
        insert(:role, name: existing.name)
      end
    end

    test "slug must be unique" do
      existing = insert(:role)

      assert_raise Ecto.ConstraintError, fn () ->
        insert(:role, slug: existing.slug)
      end
    end
  end

  describe "associations - permissions" do
    setup do
      role = :role
        |> insert
        |> with_permissions

      {:ok, role: Repo.preload(role, @preload)}
    end

    test "update associations", %{role: role} do
      new_permission = insert(:permission)

      assert length(role.permissions) == 3

      {:ok, updated} = role
        |> Role.associations_changeset(%{permissions: [new_permission]})
        |> Repo.update

      assert length(updated.permissions) == 1
      assert updated.permissions == [new_permission]
    end

    test "deleting has_many associations is possible by passing an empty list", %{role: role} do
      assert length(role.permissions) == 3

      {:ok, updated} = role
        |> Role.associations_changeset(%{permissions: []})
        |> Repo.update

      assert length(updated.permissions) == 0
      assert updated.permissions == []
    end

    test "deleting association does not remove record", %{role: role} do
      assert Repo.get(Role, role.id) != nil
      assert length(role.permissions) == 3

      Enum.map(role.permissions, &Repo.delete!(&1))

      role = Role
        |> preload(^@preload)
        |> Repo.get(role.id)

      assert Repo.get(Role, role.id) != nil
      assert length(role.permissions) == 0
    end

    test "deleting record does not remove association", %{role: role} do
      permission = hd(role.permissions)

      assert Repo.get(Permission, permission.id) != nil

      Repo.delete!(role)

      assert Repo.get(Role, role.id) == nil
      assert Repo.get(Permission, permission.id) != nil
    end
  end

  describe "associations - user roles" do
    setup do
      role = :role
        |> insert
        |> with_user_roles

      {:ok, role: Repo.preload(role, @preload)}
    end

    test "deleting association does not remove record", %{role: role} do
      assert Repo.get(Role, role.id) != nil
      assert length(role.user_roles) == 3

      Enum.map(role.user_roles, &Repo.delete(&1))

      role = Role
        |> preload(^@preload)
        |> Repo.get(role.id)

      assert Repo.get(Role, role.id) != nil
      assert length(role.user_roles) == 0
    end

    test "deleting record removes associations", %{role: role} do
      assert Repo.get(Role, role.id) != nil
      assert length(role.user_roles) == 3

      Repo.delete(role)

      assert Repo.get(Role, role.id) == nil

      Enum.map(role.user_roles, fn (user_role) ->
        assert Repo.get(UserRole, user_role.id) == nil
      end)
    end
  end
end
