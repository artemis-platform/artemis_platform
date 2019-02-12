defmodule Atlas.CreateFeature do
  use Atlas.Context

  alias Atlas.Feature
  alias Atlas.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error creating feature")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn () ->
      params
      |> insert_record
      |> Event.broadcast("feature:created", user)
    end)
  end

  defp insert_record(params) do
    %Feature{}
    |> Feature.changeset(params)
    |> Repo.insert
  end
end
