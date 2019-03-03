defmodule Artemis.CreatePermissionTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreatePermission

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn () ->
        CreatePermission.call!(%{}, Mock.system_user())
      end
    end

    test "creates a permission when passed valid params" do
      params = params_for(:permission)

      permission = CreatePermission.call!(params, Mock.system_user())

      assert permission.name == params.name
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreatePermission.call(%{}, Mock.system_user())

      assert errors_on(changeset).slug == ["can't be blank"]
    end

    test "creates a permission when passed valid params" do
      params = params_for(:permission)

      {:ok, permission} = CreatePermission.call(params, Mock.system_user())

      assert permission.name == params.name
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, permission} = CreatePermission.call(params_for(:permission), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "permission:created",
        payload: %{
          data: ^permission
        }
      }
    end
  end
end
