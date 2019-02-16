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

      assert ListRoles.call()  == [role]
    end

    test "returns a list of roles" do
      count = 3
      insert_list(count, :role)

      roles = ListRoles.call()

      assert length(roles) == count
    end
  end

  describe "call - params" do
    setup do
      role = insert(:role)

      {:ok, role: role}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys = ListRoles.call(params)
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
      roles = ListRoles.call()
      role = hd(roles)

      assert !is_list(role.user_roles)
      assert role.user_roles.__struct__ == Ecto.Association.NotLoaded

      params = %{
        preload: [:user_roles]
      }

      roles = ListRoles.call(params)
      role = hd(roles)

      assert is_list(role.user_roles)
    end
  end
end
