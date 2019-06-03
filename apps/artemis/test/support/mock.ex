defmodule Artemis.Mock do
  alias Artemis.Repo
  alias Artemis.User

  def system_user() do
    params = Application.fetch_env!(:artemis, :users)[:system_user]

    Repo.get_by(User, email: params.email)
  end

  def user_without_permissions(), do: Artemis.Factories.insert(:user)

  def user_with_permission(permission), do: user_with_permissions([permission])

  def user_with_permissions(permissions) do
    user =
      :user
      |> Artemis.Factories.insert()
      |> Artemis.Factories.with_user_roles(1)

    Enum.reduce(permissions, user, fn permission, acc ->
      Artemis.Factories.with_permission(acc, permission)
    end)
  end
end
