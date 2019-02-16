defmodule Atlas.ListPermissionsTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.ListPermissions
  alias Atlas.Repo
  alias Atlas.Permission

  setup do
    Repo.delete_all(Permission)

    {:ok, []}
  end

  describe "call" do

    test "returns empty list when no permissions exist" do
      assert ListPermissions.call() == []
    end

    test "returns existing permission" do
      permission = insert(:permission)

      assert ListPermissions.call()  == [permission]
    end

    test "returns a list of permissions" do
      count = 3
      insert_list(count, :permission)

      permissions = ListPermissions.call()

      assert length(permissions) == count
    end
  end

  describe "call - params" do
    setup do
      permission = insert(:permission)

      {:ok, permission: permission}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys = ListPermissions.call(params)
        |> Map.from_struct()
        |> Map.keys()

      pagination_keys = [
        :entries,
        :page_number,
        :page_size,
        :total_entries,
        :total_pages
      ]

      assert response_keys == pagination_keys
    end

    test "preload" do
      permissions = ListPermissions.call()
      permission = hd(permissions)

      assert !is_list(permission.permission_roles)
      assert permission.permission_roles.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:permission_roles]
      ]

      permissions = ListPermissions.call(options)
      permission = hd(permissions)

      assert is_list(permission.permission_roles)
    end
  end
end
