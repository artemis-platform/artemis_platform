defmodule Atlas.UpdateUser do
  use Atlas.Context
  use Assoc.Updater, repo: Atlas.Repo

  alias Atlas.Repo
  alias Atlas.User

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error updating user")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn () ->
      id
      |> get_record
      |> update_record(params)
      |> update_associations(params)
      |> Event.broadcast("user:updated", user)
    end)
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(User, id)

  defp update_record(nil, _params), do: {:error, "Record not found"}
  defp update_record(record, params) do
    record
    |> User.changeset(params)
    |> Repo.update
  end
end
