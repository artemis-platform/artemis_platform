defmodule Artemis.CreatePermission do
  use Artemis.Context

  alias Artemis.Permission
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating permission")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("permission:created", user)
    end)
  end

  defp insert_record(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert()
  end
end
