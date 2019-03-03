defmodule Artemis.DeletePermissionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Permission
  alias Artemis.DeletePermission

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000

      assert_raise Artemis.Context.Error, fn () ->
        DeletePermission.call!(invalid_id, Mock.system_user())
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:permission)

      %Permission{} = DeletePermission.call!(record, Mock.system_user())

      assert Repo.get(Permission, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:permission)

      %Permission{} = DeletePermission.call!(record.id, Mock.system_user())

      assert Repo.get(Permission, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50000000

      {:error, _} = DeletePermission.call(invalid_id, Mock.system_user())
    end

    test "updates a record when passed valid params" do
      record = insert(:permission)

      {:ok, _} = DeletePermission.call(record, Mock.system_user())

      assert Repo.get(Permission, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:permission)

      {:ok, _} = DeletePermission.call(record.id, Mock.system_user())

      assert Repo.get(Permission, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, permission} = DeletePermission.call(insert(:permission), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "permission:deleted",
        payload: %{
          data: ^permission
        }
      }
    end
  end
end
