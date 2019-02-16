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
  end
end
