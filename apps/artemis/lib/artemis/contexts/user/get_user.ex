defmodule Artemis.GetUser do
  use Artemis.Context

  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.User

  @default_preload []

  def call!(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by!/2)
  end

  def call(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by/2)
  end

  defp get_record(value, user, options, get_by) when not is_list(value) do
    get_record([id: value], user, options, get_by)
  end

  defp get_record(value, user, options, get_by) do
    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> restrict_access(user)
    |> get_by.(value)
  end

  defp restrict_access(query, user) do
    cond do
      has?(user, "users:access:all") -> query
      has?(user, "users:access:self") -> where(query, [u], u.id == ^user.id)
      true -> where(query, [u], is_nil(u.id))
    end
  end
end
