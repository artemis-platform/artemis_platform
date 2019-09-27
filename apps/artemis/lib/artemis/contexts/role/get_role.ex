defmodule Artemis.GetRole do
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.Role

  @default_preload []

  def call!(value, _user, options \\ []) do
    get_record(value, options, &Repo.get_by!/2)
  end

  def call(value, _user, options \\ []) do
    get_record(value, options, &Repo.get_by/2)
  end

  defp get_record(value, options, get_by) when not is_list(value) do
    get_record([id: value], options, get_by)
  end

  defp get_record(value, options, get_by) do
    Role
    |> select_fields()
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(value)
  end

  defp select_fields(query) do
    query
    |> group_by([role], role.id)
    |> join(:left, [role], user_roles in assoc(role, :user_roles))
    |> select([role, ..., user_roles], %Role{role | user_count: count(user_roles.id)})
  end
end
