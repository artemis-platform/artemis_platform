defmodule Atlas.ListRolesTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.ListRoles
  alias Atlas.Repo
  alias Atlas.Role

  setup do
    Repo.delete_all(Role)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no roles exist" do
      assert ListRoles.call() == []
    end

    test "returns existing role" do
      role = insert(:role)

      assert ListRoles.call() == [role]
    end

    test "returns list of roles" do
      count = 3
      insert_list(count, :role)

      assert length(ListRoles.call()) == count
    end
  end

  describe "call - options" do
    setup do
      role = insert(:role)

      {:ok, role: role}
    end

    test "preload" do
      roles = ListRoles.call()
      role = hd(roles)

      assert !is_list(role.permissions)
      assert role.permissions.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:permissions]
      ]

      roles = ListRoles.call(options)
      role = hd(roles)

      assert is_list(role.permissions)
    end
  end
end
