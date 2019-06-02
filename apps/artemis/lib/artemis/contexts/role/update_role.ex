defmodule Artemis.UpdateRole do
  use Artemis.Context
  use Assoc.Updater, repo: Artemis.Repo

  alias Artemis.GetRole
  alias Artemis.Repo
  alias Artemis.Role

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating role")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> update_associations(params)
      |> Event.broadcast("role:updated", user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetRole.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    record
    |> Role.changeset(params)
    |> Repo.update()
  end
end
