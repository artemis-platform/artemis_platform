defmodule Atlas.CreateRoleTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.CreateRole

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Atlas.Context.Error, fn () ->
        CreateRole.call!(%{})
      end
    end

    test "creates a role when passed valid params" do
      params = params_for(:role)

      role = CreateRole.call!(params)

      assert role.name == params.name
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateRole.call(%{})

      assert errors_on(changeset).name == ["can't be blank"]
    end

    test "creates a role when passed valid params" do
      params = params_for(:role)

      {:ok, role} = CreateRole.call(params)

      assert role.name == params.name
    end

    test "creates role with associations" do
      params = :role
        |> params_for
        |> Map.put(:permissions, [params_for(:permission), params_for(:permission)])

      {:ok, role} = CreateRole.call(params)

      assert role.name == params.name
      assert length(role.permissions) == 2
    end
  end
end
