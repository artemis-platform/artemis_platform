defmodule Artemis.UserTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.AuthProvider
  alias Artemis.Repo
  alias Artemis.User
  alias Artemis.UserRole

  @preload [:auth_providers, :roles, :user_roles]

  describe "attributes - constraints" do
    test "email must be unique" do
      existing = insert(:user)

      assert_raise Ecto.ConstraintError, fn ->
        insert(:user, email: existing.email)
      end
    end
  end

  describe "associations - auth providers" do
    setup do
      user =
        :user
        |> insert
        |> with_auth_providers

      {:ok, user: Repo.preload(user, @preload)}
    end

    test "cannot update associations through parent", %{user: user} do
      new_auth_provider = insert(:auth_provider, user: user)

      user =
        User
        |> preload(^@preload)
        |> Repo.get(user.id)

      assert length(user.auth_providers) == 4

      {:ok, updated} =
        user
        |> User.associations_changeset(%{auth_providers: [new_auth_provider]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.auth_providers) == 4
    end

    test "deleting association does not remove record", %{user: user} do
      assert Repo.get(User, user.id) != nil
      assert length(user.auth_providers) == 3

      Enum.map(user.auth_providers, &Repo.delete(&1))

      user =
        User
        |> preload(^@preload)
        |> Repo.get(user.id)

      assert Repo.get(User, user.id) != nil
      assert length(user.auth_providers) == 0
    end

    test "deleting record deletes associations", %{user: user} do
      assert Repo.get(User, user.id) != nil
      assert length(user.auth_providers) == 3

      Enum.map(user.auth_providers, fn auth_provider ->
        assert Repo.get(AuthProvider, auth_provider.id).user_id == user.id
      end)

      Repo.delete(user)

      assert Repo.get(User, user.id) == nil

      Enum.map(user.auth_providers, fn auth_provider ->
        assert Repo.get(AuthProvider, auth_provider.id) == nil
      end)
    end
  end

  describe "associations - user roles" do
    setup do
      user =
        :user
        |> insert
        |> with_user_roles

      {:ok, user: Repo.preload(user, @preload)}
    end

    test "update associations", %{user: user} do
      new_role = insert(:role)
      new_user_role = insert(:user_role, role: new_role, user: user)

      assert length(user.roles) == 3

      {:ok, updated} =
        user
        |> User.associations_changeset(%{user_roles: [new_user_role]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.roles) == 1
      assert updated.roles == [new_role]
    end

    test "deleting association does not remove record", %{user: user} do
      assert Repo.get(User, user.id) != nil
      assert length(user.user_roles) == 3

      Enum.map(user.user_roles, &Repo.delete(&1))

      user =
        User
        |> preload(^@preload)
        |> Repo.get(user.id)

      assert Repo.get(User, user.id) != nil
      assert length(user.user_roles) == 0
    end

    test "deleting record removes associations", %{user: user} do
      assert Repo.get(User, user.id) != nil
      assert length(user.user_roles) == 3

      Repo.delete(user)

      assert Repo.get(User, user.id) == nil

      Enum.map(user.user_roles, fn user_role ->
        assert Repo.get(UserRole, user_role.id) == nil
      end)
    end
  end
end
