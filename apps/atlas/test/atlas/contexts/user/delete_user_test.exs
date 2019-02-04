defmodule Atlas.DeleteUserTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.User
  alias Atlas.DeleteUser

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000

      assert_raise Atlas.Context.Error, fn () ->
        DeleteUser.call!(invalid_id)
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:user)

      %User{} = DeleteUser.call!(record)

      assert Repo.get(User, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:user)

      %User{} = DeleteUser.call!(record.id)

      assert Repo.get(User, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50000000

      {:error, _} = DeleteUser.call(invalid_id)
    end

    test "updates a record when passed valid params" do
      record = insert(:user)

      {:ok, _} = DeleteUser.call(record)

      assert Repo.get(User, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:user)

      {:ok, _} = DeleteUser.call(record.id)

      assert Repo.get(User, record.id) == nil
    end
  end
end
