defmodule Atlas.CreateRoleTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.CreateRole

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Atlas.Context.Error, fn () ->
        CreateRole.call!(%{}, Mock.root_user())
      end
    end

    test "creates a role when passed valid params" do
      params = params_for(:role)

      role = CreateRole.call!(params, Mock.root_user())

      assert role.name == params.name
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateRole.call(%{}, Mock.root_user())

      assert errors_on(changeset).name == ["can't be blank"]
    end

    test "creates a role when passed valid params" do
      params = params_for(:role)

      {:ok, role} = CreateRole.call(params, Mock.root_user())

      assert role.name == params.name
    end

    test "creates role with associations" do
      params = :role
        |> params_for
        |> Map.put(:permissions, [params_for(:permission), params_for(:permission)])

      {:ok, role} = CreateRole.call(params, Mock.root_user())

      assert role.name == params.name
      assert length(role.permissions) == 2
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      AtlasPubSub.subscribe(Atlas.Event.get_broadcast_topic())

      {:ok, role} = CreateRole.call(params_for(:role), Mock.root_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "role:created",
        payload: %{
          data: ^role
        }
      }
    end
  end
end
