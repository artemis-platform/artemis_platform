defmodule Artemis.DeleteRoleTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Role
  alias Artemis.DeleteRole

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000

      assert_raise Artemis.Context.Error, fn () ->
        DeleteRole.call!(invalid_id, Mock.system_user())
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:role)

      %Role{} = DeleteRole.call!(record, Mock.system_user())

      assert Repo.get(Role, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:role)

      %Role{} = DeleteRole.call!(record.id, Mock.system_user())

      assert Repo.get(Role, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50000000

      {:error, _} = DeleteRole.call(invalid_id, Mock.system_user())
    end

    test "updates a record when passed valid params" do
      record = insert(:role)

      {:ok, _} = DeleteRole.call(record, Mock.system_user())

      assert Repo.get(Role, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:role)

      {:ok, _} = DeleteRole.call(record.id, Mock.system_user())

      assert Repo.get(Role, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, role} = DeleteRole.call(insert(:role), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "role:deleted",
        payload: %{
          data: ^role
        }
      }
    end
  end
end
