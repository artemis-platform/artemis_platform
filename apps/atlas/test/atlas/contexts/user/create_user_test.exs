defmodule Atlas.CreateUserTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.CreateUser

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Atlas.Context.Error, fn () ->
        CreateUser.call!(%{})
      end
    end

    test "creates a user when passed valid params" do
      params = params_for(:user)

      user = CreateUser.call!(params)

      assert user.email == params.email
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateUser.call(%{})

      assert errors_on(changeset).email == ["can't be blank"]
    end

    test "creates a user when passed valid params" do
      params = params_for(:user)

      {:ok, user} = CreateUser.call(params)

      assert user.email == params.email
    end

    test "creates user with associations" do
      params = :user
        |> params_for
        |> Map.put(:user_roles, [params_for(:user_role), params_for(:user_role)])

      {:ok, user} = CreateUser.call(params)

      assert user.email == params.email
      assert length(user.user_roles) == 2
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      AtlasPubSub.subscribe(Atlas.Context.broadcast_topic())

      {:ok, user} = CreateUser.call(params_for(:user))

      assert_received %Phoenix.Socket.Broadcast{
        event: "user:created",
        payload: ^user
      }
    end
  end
end
