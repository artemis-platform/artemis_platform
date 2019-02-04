defmodule Atlas.GetRoleTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.GetRole

  setup do
    role = insert(:role)
    insert(:permission, roles: [role])

    {:ok, role: role}
  end

  describe "call" do
    test "returns nil role not found" do
      invalid_id = 50000000

      assert GetRole.call(invalid_id) == nil
    end

    test "finds role by id", %{role: role} do
      assert GetRole.call(role.id) == role
    end
  end

  describe "call - options" do
    test "preload", %{role: role} do
      role = GetRole.call(role.id)

      assert !is_list(role.permissions)
      assert role.permissions.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:permissions]
      ]

      role = GetRole.call(role.id, options)

      assert is_list(role.permissions)
    end
  end

  describe "call!" do
    test "raises an exception role not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetRole.call!(invalid_id) == nil
      end
    end

    test "finds role by id", %{role: role} do
      assert GetRole.call!(role.id) == role
    end
  end
end
