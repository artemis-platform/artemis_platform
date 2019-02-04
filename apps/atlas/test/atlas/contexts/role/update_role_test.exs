defmodule Atlas.UpdateRoleTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.UpdateRole

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000
      params = params_for(:role)

      assert_raise Atlas.Context.Error, fn () ->
        UpdateRole.call!(invalid_id, params)
      end
    end

    test "returns successfully when params are empty" do
      role = insert(:role)
      params = %{}

      updated = UpdateRole.call!(role, params)

      assert updated.name == role.name
    end

    test "updates a record when passed valid params" do
      role = insert(:role)
      params = params_for(:role)

      updated = UpdateRole.call!(role, params)

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      role = insert(:role)
      params = params_for(:role)

      updated = UpdateRole.call!(role.id, params)

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50000000
      params = params_for(:role)

      {:error, _} = UpdateRole.call(invalid_id, params)
    end

    test "returns successfully when params are empty" do
      role = insert(:role)
      params = %{}

      {:ok, updated} = UpdateRole.call(role, params)

      assert updated.name == role.name
    end

    test "updates a record when passed valid params" do
      role = insert(:role)
      params = params_for(:role)

      {:ok, updated} = UpdateRole.call(role, params)

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      role = insert(:role)
      params = params_for(:role)

      {:ok, updated} = UpdateRole.call(role.id, params)

      assert updated.name == params.name
    end
  end

  describe "call - associations" do
    test "adds associations and updates record" do
      permission = insert(:permission)
      role = insert(:role)

      role = Repo.preload(role, [:permissions])

      assert role.permissions == []

      # Add Association

      params = %{
        id: role.id,
        name: "Updated Name",
        permissions: [
          %{id: permission.id}
        ]
      }

      {:ok, updated} = UpdateRole.call(role.id, params)

      assert updated.permissions != []
      assert updated.name == "Updated Name"
    end

    test "removes associations when explicitly passed an empty value" do
      role = :role
        |> insert
        |> with_permissions

      role = Repo.preload(role, [:permissions])

      assert length(role.permissions) == 3

      # Keeps existing associations if the association key is not passed

      params = %{
        id: role.id,
        name: "New Name"
      }

      {:ok, updated} = UpdateRole.call(role.id, params)

      assert length(updated.permissions) == 3

      # Only removes associations when the association key is explicitly passed

      params = %{
        id: role.id,
        permissions: []
      }

      {:ok, updated} = UpdateRole.call(role.id, params)

      assert length(updated.permissions) == 0
    end
  end
end
