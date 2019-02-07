defmodule Atlas.CreateRole do
  use Atlas.Context
  use Assoc.Updater, repo: Atlas.Repo

  import Atlas.Repo.Util

  alias Atlas.Repo
  alias Atlas.Role

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error creating role")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn () ->
      params
      |> insert_record
      |> update_associations(params)
      |> Event.broadcast("role:created", user)
    end)
  end

  defp insert_record(params) do
    %Role{}
    |> Role.changeset(params)
    |> Repo.insert
  end
end
