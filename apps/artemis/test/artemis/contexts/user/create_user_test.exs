defmodule Artemis.CreateUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateUser

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateUser.call!(%{}, Mock.system_user())
      end
    end

    test "creates a user when passed valid params" do
      params = params_for(:user)

      user = CreateUser.call!(params, Mock.system_user())

      assert user.email == params.email
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateUser.call(%{}, Mock.system_user())

      assert errors_on(changeset).email == ["can't be blank"]
    end

    test "creates a user when passed valid params" do
      params = params_for(:user)

      {:ok, user} = CreateUser.call(params, Mock.system_user())

      assert user.email == params.email
    end

    test "generates a client key and client secret" do
      params = params_for(:user)

      {:ok, user} = CreateUser.call(params, Mock.system_user())

      assert byte_size(user.client_key) == 30
      assert byte_size(user.client_secret) == 100
    end

    test "creates user with associations" do
      params =
        :user
        |> params_for
        |> Map.put(:user_roles, [params_for(:user_role), params_for(:user_role)])

      {:ok, user} = CreateUser.call(params, Mock.system_user())

      assert user.email == params.email
      assert length(user.user_roles) == 2
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, user} = CreateUser.call(params_for(:user), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "user:created",
        payload: %{
          data: ^user
        }
      }
    end
  end
end
