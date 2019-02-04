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

      assert ListUsers.call() == [user]
    end

    test "returns list of users" do
      count = 3
      insert_list(count, :user)

      assert length(ListUsers.call()) == count
    end
  end

  describe "call - options" do
    setup do
      user = insert(:user)

      {:ok, user: user}
    end

    test "preload" do
      users = ListUsers.call()
      user = hd(users)

      assert !is_list(user.user_roles)
      assert user.user_roles.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:user_roles]
      ]

      users = ListUsers.call(options)
      user = hd(users)

      assert is_list(user.user_roles)
    end
  end
end
