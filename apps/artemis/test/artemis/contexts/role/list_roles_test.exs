defmodule Artemis.ListRolesTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListRoles
  alias Artemis.Repo
  alias Artemis.Role

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

    test "query - search" do
      insert(:role, name: "John Smith", slug: "john-smith")
      insert(:role, name: "Jill Smith", slug: "jill-smith")
      insert(:role, name: "John Doe", slug: "john-doe")

      roles = ListRoles.call()

      assert length(roles) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      roles = ListRoles.call(params)

      assert length(roles) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "john-"
      }

      roles = ListRoles.call(params)

      assert length(roles) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith"
      }

      roles = ListRoles.call(params)

      assert length(roles) == 0
    end
  end
end
