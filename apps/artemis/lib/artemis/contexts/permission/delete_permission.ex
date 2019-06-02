defmodule Artemis.DeletePermission do
  use Artemis.Context

  alias Artemis.GetPermission
  alias Artemis.Repo

  def call!(id, user) do
    case call(id, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting permission")
      {:ok, result} -> result
    end
  end

  def call(id, user) do
    id
    |> get_record(user)
    |> delete_record
    |> Event.broadcast("permission:deleted", user)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetPermission.call(id, user)

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
