defmodule Artemis.UserRoleTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Repo
  alias Artemis.Role
  alias Artemis.UserRole
  alias Artemis.User

  @preload [:created_by, :role, :user]

  describe "associations - created by" do
    setup do
      user_role = insert(:user_role)

      {:ok, user_role: Repo.preload(user_role, @preload)}
    end

    test "deleting association does not remove record and nilifies foreign key", %{user_role: user_role} do
      assert Repo.get(User, user_role.created_by.id) != nil
      assert user_role.created_by != nil

      Repo.delete!(user_role.created_by)

      assert Repo.get(User, user_role.created_by.id) == nil

      user_role = UserRole
        |> preload(^@preload)
        |> Repo.get(user_role.id)

      assert user_role.created_by == nil
    end

    test "deleting record does not remove association", %{user_role: user_role} do
      assert Repo.get(User, user_role.created_by.id) != nil

      Repo.delete!(user_role)

      assert Repo.get(User, user_role.created_by.id) != nil
      assert Repo.get(UserRole, user_role.id) == nil
    end
  end

  describe "associations - role" do
    setup do
      user_role = insert(:user_role)

      {:ok, user_role: Repo.preload(user_role, @preload)}
    end

    test "deleting association removes record", %{user_role: user_role} do
      assert Repo.get(Role, user_role.role.id) != nil

      Repo.delete!(user_role.role)

      assert Repo.get(Role, user_role.role.id) == nil
      assert Repo.get(UserRole, user_role.id) == nil
    end

    test "deleting record does not remove association", %{user_role: user_role} do
      assert Repo.get(Role, user_role.role.id) != nil

      Repo.delete!(user_role)

      assert Repo.get(Role, user_role.role.id) != nil
      assert Repo.get(UserRole, user_role.id) == nil
    end
  end

  describe "associations - user" do
    setup do
      user_role = insert(:user_role)

      {:ok, user_role: Repo.preload(user_role, @preload)}
    end

    test "deleting association removes record", %{user_role: user_role} do
      assert Repo.get(User, user_role.user.id) != nil

      Repo.delete!(user_role.user)

      assert Repo.get(User, user_role.user.id) == nil
      assert Repo.get(UserRole, user_role.id) == nil
    end

    test "deleting record does not remove association", %{user_role: user_role} do
      assert Repo.get(User, user_role.user.id) != nil

      Repo.delete!(user_role)

      assert Repo.get(User, user_role.user.id) != nil
      assert Repo.get(UserRole, user_role.id) == nil
    end
  end
end
