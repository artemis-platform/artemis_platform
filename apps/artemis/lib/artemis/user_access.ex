defmodule Artemis.UserAccess do
  alias Artemis.Repo
  alias Artemis.User

  # User Permissions - Boolean Queries

  def has?(%User{} = user, permission) when is_bitstring(permission), do: has_any?(user, [permission])
  def has?(_, _), do: false

  def has_any?(%User{} = user, permission) when is_bitstring(permission), do: has_any?(user, [permission])

  def has_any?(%User{} = user, permissions) when is_list(permissions) do
    permissions
    |> MapSet.new()
    |> MapSet.disjoint?(user_permissions(user))
    |> Kernel.not()
  end

  def has_any?(_, _), do: false

  def has_all?(%User{} = user, permission) when is_bitstring(permission), do: has_all?(user, [permission])
  def has_all?(%User{} = _user, permissions) when length(permissions) == 0, do: false

  def has_all?(%User{} = user, permissions) when is_list(permissions) do
    permissions
    |> MapSet.new()
    |> MapSet.subset?(user_permissions(user))
  end

  def has_all?(_, _), do: false

  # Helpers

  defp user_permissions(user) do
    user
    |> Repo.preload([:permissions])
    |> Map.get(:permissions)
    |> Enum.map(& &1.slug)
    |> MapSet.new()
  end
end
