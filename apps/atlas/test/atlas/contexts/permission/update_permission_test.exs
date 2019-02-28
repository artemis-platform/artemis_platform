defmodule Atlas.UpdatePermissionTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.UpdatePermission

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000
      params = params_for(:permission)

      assert_raise Atlas.Context.Error, fn () ->
        UpdatePermission.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      permission = insert(:permission)
      params = %{}

      updated = UpdatePermission.call!(permission, params, Mock.system_user())

      assert updated.name == permission.name
    end

    test "updates a record when passed valid params" do
      permission = insert(:permission)
      params = params_for(:permission)

      updated = UpdatePermission.call!(permission, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      permission = insert(:permission)
      params = params_for(:permission)

      updated = UpdatePermission.call!(permission.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50000000
      params = params_for(:permission)

      {:error, _} = UpdatePermission.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      permission = insert(:permission)
      params = %{}

      {:ok, updated} = UpdatePermission.call(permission, params, Mock.system_user())

      assert updated.name == permission.name
    end

    test "updates a record when passed valid params" do
      permission = insert(:permission)
      params = params_for(:permission)

      {:ok, updated} = UpdatePermission.call(permission, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      permission = insert(:permission)
      params = params_for(:permission)

      {:ok, updated} = UpdatePermission.call(permission.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      AtlasPubSub.subscribe(Atlas.Event.get_broadcast_topic())

      permission = insert(:permission)
      params = params_for(:permission)

      {:ok, updated} = UpdatePermission.call(permission, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "permission:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
