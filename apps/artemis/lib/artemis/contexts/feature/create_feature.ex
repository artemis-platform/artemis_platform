defmodule Artemis.CreateFeature do
  use Artemis.Context

  alias Artemis.Feature
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating feature")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("feature:created", user)
    end)
  end

  defp insert_record(params) do
    %Feature{}
    |> Feature.changeset(params)
    |> Repo.insert()
  end
end
