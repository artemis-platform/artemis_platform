defmodule Atlas.DeleteRole do
  use Atlas.Context

  alias Atlas.Repo
  alias Atlas.Role

  def call!(id) do
    case call(id) do
      {:error, _} -> raise(Atlas.Context.Error, "Error deleting role")
      {:ok, result} -> result
    end
  end

  def call(id) do
    id
    |> get_record
    |> delete_record
    |> broadcast_result("role:deleted")
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(Role, id)

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
