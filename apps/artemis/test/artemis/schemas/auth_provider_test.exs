defmodule Artemis.AuthProviderTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.AuthProvider
  alias Artemis.Repo
  alias Artemis.User

  @preload [:user]

  describe "associations - user" do
    setup do
      auth_provider = insert(:auth_provider)

      {:ok, auth_provider: Repo.preload(auth_provider, @preload)}
    end

    test "updating association does not change record", %{auth_provider: auth_provider} do
      user = Repo.get(User, auth_provider.user.id)

      assert user != nil
      assert user.name != "Updated Name"

      params = %{name: "Updated Name"}

      {:ok, user} =
        user
        |> User.changeset(params)
        |> Repo.update()

      assert user != nil
      assert user.name == "Updated Name"

      assert Repo.get(AuthProvider, auth_provider.id).user_id == user.id
    end

    test "deleting association deletes record", %{auth_provider: auth_provider} do
      assert Repo.get(User, auth_provider.user.id) != nil

      Repo.delete!(auth_provider.user)

      assert Repo.get(User, auth_provider.user.id) == nil
      assert Repo.get(AuthProvider, auth_provider.id) == nil
    end

    test "deleting record does not remove association", %{auth_provider: auth_provider} do
      assert Repo.get(User, auth_provider.user.id) != nil

      Repo.delete!(auth_provider)

      assert Repo.get(User, auth_provider.user.id) != nil
      assert Repo.get(AuthProvider, auth_provider.id) == nil
    end
  end
end
