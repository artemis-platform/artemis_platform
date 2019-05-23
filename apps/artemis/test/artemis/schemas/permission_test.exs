defmodule Artemis.PermissionTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Permission
  alias Artemis.Repo
  alias Artemis.Role

  @preload [:roles]

  describe "attributes - constraints" do
    test "name must be unique" do
      existing = insert(:permission)

      assert_raise Ecto.ConstraintError, fn ->
        insert(:permission, slug: existing.slug)
      end
    end
  end

  describe "associations - roles" do
    setup do
      permission =
        :permission
        |> insert
        |> with_roles

      {:ok, permission: Repo.preload(permission, @preload)}
    end

    test "deleting association does not remove record", %{permission: permission} do
      assert Repo.get(Permission, permission.id) != nil
      assert length(permission.roles) == 3

      Enum.map(permission.roles, &Repo.delete!(&1))

      permission =
        Permission
        |> preload(^@preload)
        |> Repo.get(permission.id)

      assert Repo.get(Permission, permission.id) != nil
      assert length(permission.roles) == 0
    end

    test "deleting record does not remove association", %{permission: permission} do
      role = hd(permission.roles)

      assert Repo.get(Role, role.id) != nil

      Repo.delete!(permission)

      assert Repo.get(Permission, permission.id) == nil
      assert Repo.get(Role, role.id) != nil
    end
  end
end
