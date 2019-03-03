defmodule Artemis.DeleteUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.User
  alias Artemis.DeleteUser

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000

      assert_raise Artemis.Context.Error, fn () ->
        DeleteUser.call!(invalid_id, Mock.system_user())
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:user)

      %User{} = DeleteUser.call!(record, Mock.system_user())

      assert Repo.get(User, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:user)

      %User{} = DeleteUser.call!(record.id, Mock.system_user())

      assert Repo.get(User, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50000000

      {:error, _} = DeleteUser.call(invalid_id, Mock.system_user())
    end

    test "updates a record when passed valid params" do
      record = insert(:user)

      {:ok, _} = DeleteUser.call(record, Mock.system_user())

      assert Repo.get(User, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:user)

      {:ok, _} = DeleteUser.call(record.id, Mock.system_user())

      assert Repo.get(User, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, user} = DeleteUser.call(insert(:user), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "user:deleted",
        payload: %{
          data: ^user
        }
      }
    end
  end
end
