defmodule Atlas.UpdateRole do
  use Atlas.Context
  use Assoc.Updater, repo: Atlas.Repo

  import Atlas.Repo.Util

  alias Atlas.Repo
  alias Atlas.Role

  def call!(id, params) do
    case call(id, params) do
      {:error, _} -> raise(Atlas.Context.Error, "Error updating role")
      {:ok, result} -> result
    end
  end

  def call(id, params) do
    with_transaction(fn () ->
      id
      |> get_record
      |> update_record(params)
      |> update_associations(params)
      |> broadcast_result("role:updated")
    end)
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(Role, id)

  defp update_record(nil, _params), do: {:error, "Record not found"}
  defp update_record(record, params) do
    record
    |> Role.changeset(params)
    |> Repo.update
  end
end
