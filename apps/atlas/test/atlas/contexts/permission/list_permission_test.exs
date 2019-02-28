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

    test "query - search" do
      insert(:permission, name: "John Smith", slug: "john-smith")
      insert(:permission, name: "Jill Smith", slug: "jill-smith")
      insert(:permission, name: "John Doe", slug: "john-doe")

      permissions = ListPermissions.call()

      assert length(permissions) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      permissions = ListPermissions.call(params)

      assert length(permissions) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "john-"
      }

      permissions = ListPermissions.call(params)

      assert length(permissions) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith"
      }

      permissions = ListPermissions.call(params)

      assert length(permissions) == 0
    end
  end
end
