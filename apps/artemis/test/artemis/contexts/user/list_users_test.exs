defmodule Artemis.ListUsersTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListUsers
  alias Artemis.Repo
  alias Artemis.User

  describe "access permissions" do
    setup do
      insert_list(3, :user)

      {:ok, []}
    end

    test "returns empty list with no permissions" do
      user = Mock.user_without_permissions()

      result = ListUsers.call(user)

      assert length(result) == 0
    end

    test "requires access:self permission to return own record" do
      user = Mock.user_with_permission("users:access:self")

      result = ListUsers.call(user)

      assert length(result) == 1
    end

    test "requires access:all permission to return other records" do
      user = Mock.user_with_permission("users:access:all")

      result = ListUsers.call(user)
      total = Repo.all(User)

      assert length(result) == length(total)
    end
  end

  describe "call" do
    test "returns empty list when no users exist" do
      Repo.delete_all(User)

      assert ListUsers.call(Mock.system_user()) == []
    end

    test "returns a list of users" do
      start = length(Repo.all(User))

      count = 3
      insert_list(count, :user)

      users = ListUsers.call(Mock.system_user())

      assert length(users) == start + count
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
      insert(:user, name: "Four Six", email: "four-six")
      insert(:user, name: "Four Two", email: "four-two")
      insert(:user, name: "Five Six", email: "five-six")

      users = ListUsers.call(Mock.system_user())

      assert length(users) > 2

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "four-"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      users = ListUsers.call(params, Mock.system_user())

      assert length(users) == 0
    end
  end
end
