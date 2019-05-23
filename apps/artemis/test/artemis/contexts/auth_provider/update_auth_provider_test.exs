defmodule Artemis.UpdateAuthProviderTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateAuthProvider

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:auth_provider)

      assert_raise Artemis.Context.Error, fn ->
        UpdateAuthProvider.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      auth_provider = insert(:auth_provider)
      params = %{}

      updated = UpdateAuthProvider.call!(auth_provider, params, Mock.system_user())

      assert updated.type == auth_provider.type
      assert updated.uid == auth_provider.uid
    end

    test "updates a record when passed valid params" do
      auth_provider = insert(:auth_provider)
      params = params_for(:auth_provider)

      updated = UpdateAuthProvider.call!(auth_provider, params, Mock.system_user())

      assert updated.type == params.type
      assert updated.uid == params.uid
    end

    test "updates a record when passed an id and valid params" do
      auth_provider = insert(:auth_provider)
      params = params_for(:auth_provider)

      updated = UpdateAuthProvider.call!(auth_provider.id, params, Mock.system_user())

      assert updated.type == params.type
      assert updated.uid == params.uid
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:auth_provider)

      {:error, _} = UpdateAuthProvider.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      auth_provider = insert(:auth_provider)
      params = %{}

      {:ok, updated} = UpdateAuthProvider.call(auth_provider, params, Mock.system_user())

      assert updated.type == auth_provider.type
      assert updated.uid == auth_provider.uid
    end

    test "updates a record when passed valid params" do
      auth_provider = insert(:auth_provider)
      params = params_for(:auth_provider)

      {:ok, updated} = UpdateAuthProvider.call(auth_provider, params, Mock.system_user())

      assert updated.type == params.type
      assert updated.uid == params.uid
    end

    test "updates a record when passed an id and valid params" do
      auth_provider = insert(:auth_provider)
      params = params_for(:auth_provider)

      {:ok, updated} = UpdateAuthProvider.call(auth_provider.id, params, Mock.system_user())

      assert updated.type == params.type
      assert updated.uid == params.uid
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      auth_provider = insert(:auth_provider)
      params = params_for(:auth_provider)

      {:ok, updated} = UpdateAuthProvider.call(auth_provider, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "auth-provider:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
