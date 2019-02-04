defmodule Atlas.DeleteRoleTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.Role
  alias Atlas.DeleteRole

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000

      assert_raise Atlas.Context.Error, fn () ->
        DeleteRole.call!(invalid_id)
      end
    end

    test "updates a record when passed valid params" do
      record = insert(:role)

      %Role{} = DeleteRole.call!(record)

      assert Repo.get(Role, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:role)

      %Role{} = DeleteRole.call!(record.id)

      assert Repo.get(Role, record.id) == nil
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50000000

      {:error, _} = DeleteRole.call(invalid_id)
    end

    test "updates a record when passed valid params" do
      record = insert(:role)

      {:ok, _} = DeleteRole.call(record)

      assert Repo.get(Role, record.id) == nil
    end

    test "updates a record when passed an id and valid params" do
      record = insert(:role)

      {:ok, _} = DeleteRole.call(record.id)

      assert Repo.get(Role, record.id) == nil
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      AtlasPubSub.subscribe(Atlas.Context.broadcast_topic())

      {:ok, role} = DeleteRole.call(insert(:role))

      assert_received %Phoenix.Socket.Broadcast{
        event: "role:deleted",
        payload: ^role
      }
    end
  end
end
