defmodule Artemis.GetRoleTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetRole

  setup do
    role = insert(:role)
    insert(:permission, roles: [role])

    {:ok, role: role}
  end

  describe "call" do
    test "returns nil role not found" do
      invalid_id = 50_000_000

      assert GetRole.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds role by id", %{role: role} do
      assert GetRole.call(role.id, Mock.system_user()) == role
    end

    test "finds user keyword list", %{role: role} do
      assert GetRole.call([name: role.name, slug: role.slug], Mock.system_user()) == role
    end
  end

  describe "call - options" do
    test "preload", %{role: role} do
      role = GetRole.call(role.id, Mock.system_user())

      assert !is_list(role.permissions)
      assert role.permissions.__struct__ == Ecto.Association.NotLoaded

      values = [
        name: role.name,
        slug: role.slug
      ]

      options = [
        preload: [:permissions]
      ]

      role = GetRole.call(values, Mock.system_user(), options)

      assert is_list(role.permissions)
    end
  end

  describe "call!" do
    test "raises an exception role not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetRole.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds role by id", %{role: role} do
      assert GetRole.call!(role.id, Mock.system_user()) == role
    end
  end
end
