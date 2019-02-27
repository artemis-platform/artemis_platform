defmodule Atlas.UpdatePermission do
  use Atlas.Context

  alias Atlas.Permission
  alias Atlas.Repo

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error updating permission")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn () ->
      id
      |> get_record
      |> update_record(params)
      |> Event.broadcast("permission:updated", user)
    end)
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(Permission, id)

  defp update_record(nil, _params), do: {:error, "Record not found"}
  defp update_record(record, params) do
    record
    |> Permission.changeset(params)
    |> Repo.update
  end
end
