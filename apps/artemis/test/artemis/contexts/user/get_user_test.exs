defmodule Artemis.GetUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetUser

  setup do
    user = insert(:user)
    insert(:user_role, user: user)

    {:ok, user: user}
  end

  describe "access permissions" do
    test "returns nil with no permissions" do
      user = Mock.user_without_permissions()
      insert(:user_role, user: user)

      nil = GetUser.call(user.id, user)
    end

    test "requires access:self permission to return own record" do
      user = Mock.user_with_permission("users:access:self")
      insert(:user_role, user: user)

      assert GetUser.call(user.id, user).id == user.id
    end

    test "requires access:all permission to return other records" do
      user = Mock.user_with_permission("users:access:all")

      other_user = insert(:user)

      assert GetUser.call(other_user.id, user).id == other_user.id
    end
  end

  describe "call" do
    test "returns nil user not found" do
      invalid_id = 50_000_000

      assert GetUser.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds user by id", %{user: user} do
      assert GetUser.call(user.id, Mock.system_user()) == user
    end

    test "finds user keyword list", %{user: user} do
      assert GetUser.call([email: user.email, name: user.name], Mock.system_user()) == user
    end
  end

  describe "call - options" do
    test "preload", %{user: user} do
      user = GetUser.call(user.id, Mock.system_user())

      assert !is_list(user.user_roles)
      assert user.user_roles.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:user_roles]
      ]

      user = GetUser.call(user.id, Mock.system_user(), options)

      assert is_list(user.user_roles)
    end
  end

  describe "call!" do
    test "raises an exception user not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetUser.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds user by id", %{user: user} do
      assert GetUser.call!(user.id, Mock.system_user()) == user
    end
  end
end
