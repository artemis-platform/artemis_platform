defmodule Atlas.DeleteUser do
  use Atlas.Context

  alias Atlas.Repo
  alias Atlas.User

  def call!(id, user) do
    case call(id, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error deleting user")
      {:ok, result} -> result
    end
  end

  def call(id, user) do
    id
    |> get_record
    |> delete_record
    |> Event.broadcast("user:deleted", user)
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(User, id)

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
