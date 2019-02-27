defmodule Atlas.CreatePermission do
  use Atlas.Context

  alias Atlas.Permission
  alias Atlas.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error creating permission")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn () ->
      params
      |> insert_record
      |> Event.broadcast("permission:created", user)
    end)
  end

  defp insert_record(params) do
    %Permission{}
    |> Permission.changeset(params)
    |> Repo.insert
  end
end
