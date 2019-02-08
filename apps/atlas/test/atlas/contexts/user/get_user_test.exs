defmodule Atlas.GetUserTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.GetUser

  setup do
    user = insert(:user)
    insert(:user_role, user: user)

    {:ok, user: user}
  end

  describe "call" do
    test "returns nil user not found" do
      invalid_id = 50000000

      assert GetUser.call(invalid_id) == nil
    end

    test "finds user by id", %{user: user} do
      assert GetUser.call(user.id) == user
    end

    test "finds user keyword list", %{user: user} do
      assert GetUser.call(email: user.email, name: user.name) == user
    end
  end

  describe "call - options" do
    test "preload", %{user: user} do
      user = GetUser.call(user.id)

      assert !is_list(user.user_roles)
      assert user.user_roles.__struct__ == Ecto.Association.NotLoaded

      values = [
        email: user.email,
        name: user.name
      ]

      options = [
        preload: [:user_roles]
      ]

      user = GetUser.call(values, options)

      assert is_list(user.user_roles)
    end
  end

  describe "call!" do
    test "raises an exception user not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetUser.call!(invalid_id) == nil
      end
    end

    test "finds user by id", %{user: user} do
      assert GetUser.call!(user.id) == user
    end
  end
end
