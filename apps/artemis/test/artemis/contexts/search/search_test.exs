defmodule Artemis.SearchTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Search

  describe "permissions" do
    test "returns empty map when permissions are not met" do
      unauthorized_user = insert(:user)

      params = %{
        query: unauthorized_user.name
      }

      result = Search.call(params, unauthorized_user)

      assert result == %{}
    end

    test "returns key when permissions are met" do
      authorized_user =
        :user
        |> insert()
        |> with_permission("users:list")

      params = %{
        query: authorized_user.name
      }

      result = Search.call(params, authorized_user)

      entries =
        result
        |> Map.get("users")
        |> Map.get(:entries)

      user_names = Enum.map(entries, & &1.name)

      assert is_list(entries)
      assert Enum.member?(user_names, authorized_user.name)
    end
  end

  describe "call" do
    test "returns an empty map when no query param is sent" do
      %{} = Search.call(%{}, Mock.system_user())
    end

    test "returns empty pagination results when query param does not match" do
      insert_list(3, :user)

      params = %{
        query: "invalid-search"
      }

      result = Search.call(params, Mock.system_user())

      entries =
        result
        |> Map.get("users")
        |> Map.get(:entries)

      assert entries == []
    end

    test "returns matching values" do
      user = insert(:user, name: "Test User", email: "email@test.com")

      params = %{
        query: "email@"
      }

      result = Search.call(params, Mock.system_user())

      entries =
        result
        |> Map.get("users")
        |> Map.get(:entries)

      user_names = Enum.map(entries, & &1.name)

      assert is_list(entries)
      assert Enum.member?(user_names, user.name)
    end
  end

  describe "call - params" do
    test "page_size" do
      insert_list(3, :user, name: "Test User")

      params = %{
        page_size: 2,
        query: "Test User"
      }

      result = Search.call(params, Mock.system_user())

      users = Map.get(result, "users")
      entries = Map.get(users, :entries)

      assert users.page_number == 1
      assert users.page_size == 2
      assert length(entries) == 2
    end
  end
end
