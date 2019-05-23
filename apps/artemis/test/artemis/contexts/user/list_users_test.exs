defmodule Artemis.ListUsersTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListUsers
  alias Artemis.Repo
  alias Artemis.User

  setup do
    Repo.delete_all(User)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no users exist" do
      assert ListUsers.call(Mock.system_user()) == []
    end

    test "returns existing user" do
      user = insert(:user)

      assert ListUsers.call(Mock.system_user()) == [user]
    end

    test "returns a list of users" do
      count = 3
      insert_list(count, :user)

      users = ListUsers.call(Mock.system_user())

      assert length(users) == count
    end
  end

  describe "call - params" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "order" do
      insert_list(3, :user)

      params = %{order: "name"}
      ascending = ListUsers.call(params, Mock.system_user())

      params = %{order: "-name"}
      descending = ListUsers.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListUsers.call(params, Mock.system_user())
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
      users = ListUsers.call(Mock.system_user())
      user = hd(users)

      assert !is_list(user.user_roles)
      assert user.user_roles.__struct__ == Ecto.Association.NotLoaded

      params = %{
        preload: [:user_roles]
      }

      users = ListUsers.call(params, Mock.system_user())
      user = hd(users)

      assert is_list(user.user_roles)
    end

    test "query - search" do
      insert(:user, name: "John Smith", email: "johnn@smith.com")
      insert(:user, name: "Jill Smith", email: "jill@smith.com")
      insert(:user, name: "John Doe", email: "johnn@doe.com")

      users = ListUsers.call(Mock.system_user())

      assert length(users) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "johnn@"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith.com"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 0
    end
  end
end
