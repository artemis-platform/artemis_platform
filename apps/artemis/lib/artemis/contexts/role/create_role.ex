defmodule Artemis.CreateRole do
  use Artemis.Context
  use Assoc.Updater, repo: Artemis.Repo

  alias Artemis.Repo
  alias Artemis.Role

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating role")
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
