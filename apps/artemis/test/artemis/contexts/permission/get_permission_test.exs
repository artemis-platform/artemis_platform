defmodule Artemis.GetPermissionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetPermission

  setup do
    permission = insert(:permission)

    {:ok, permission: permission}
  end

  describe "call" do
    test "returns nil permission not found" do
      invalid_id = 50000000

      assert GetPermission.call(invalid_id) == nil
    end

    test "finds permission by id", %{permission: permission} do
      assert GetPermission.call(permission.id) == permission
    end

    test "finds user keyword list", %{permission: permission} do
      assert GetPermission.call(name: permission.name, slug: permission.slug) == permission
    end
  end

  describe "call!" do
    test "raises an exception permission not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetPermission.call!(invalid_id) == nil
      end
    end

    test "finds permission by id", %{permission: permission} do
      assert GetPermission.call!(permission.id) == permission
    end
  end
end
