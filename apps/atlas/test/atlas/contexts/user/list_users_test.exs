defmodule Atlas.ListUsersTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.ListUsers
  alias Atlas.Repo
  alias Atlas.User

  setup do
    Repo.delete_all(User)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no users exist" do
      assert ListUsers.call() == []
    end

    test "returns existing user" do
      user = insert(:user)

      assert ListUsers.call()  == [user]
    end

    test "returns a list of users" do
      count = 3
      insert_list(count, :user)

      users = ListUsers.call()

      assert length(users) == count
    end
  end

  describe "call - params" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys = ListUsers.call(params)
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
      users = ListUsers.call()
      user = hd(users)

      assert !is_list(user.user_roles)
      assert user.user_roles.__struct__ == Ecto.Association.NotLoaded

      params = %{
        preload: [:user_roles]
      }

      users = ListUsers.call(params)
      user = hd(users)

      assert is_list(user.user_roles)
    end

    test "query - search" do
      insert(:user, name: "John Smith", email: "john@smith.com")
      insert(:user, name: "Jill Smith", email: "jill@smith.com")
      insert(:user, name: "John Doe", email: "john@doe.com")

      users = ListUsers.call()

      assert length(users) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      users = ListUsers.call(params)

      assert length(users) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "john@"
      }

      users = ListUsers.call(params)

      assert length(users) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith.com"
      }

      users = ListUsers.call(params)

      assert length(users) == 0
    end
  end
end
