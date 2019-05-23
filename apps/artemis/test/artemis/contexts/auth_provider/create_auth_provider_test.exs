defmodule Artemis.CreateAuthProviderTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateAuthProvider

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateAuthProvider.call!(%{}, Mock.system_user())
      end
    end

    test "creates a auth provider when passed valid params" do
      params = params_for(:auth_provider)

      auth_provider = CreateAuthProvider.call!(params, Mock.system_user())

      assert auth_provider.type == params.type
      assert auth_provider.uid == params.uid
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateAuthProvider.call(%{}, Mock.system_user())

      assert errors_on(changeset).type == ["can't be blank"]
      assert errors_on(changeset).uid == ["can't be blank"]
    end

    test "creates a auth provider when passed valid params" do
      params = params_for(:auth_provider)

      {:ok, auth_provider} = CreateAuthProvider.call(params, Mock.system_user())

      assert auth_provider.type == params.type
      assert auth_provider.uid == params.uid
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, auth_provider} = CreateAuthProvider.call(params_for(:auth_provider), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "auth-provider:created",
        payload: %{
          data: ^auth_provider
        }
      }
    end
  end
end
