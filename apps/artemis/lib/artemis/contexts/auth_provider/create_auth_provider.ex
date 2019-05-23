defmodule Artemis.CreateAuthProvider do
  use Artemis.Context

  alias Artemis.AuthProvider
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating auth provider")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("auth-provider:created", user)
    end)
  end

  defp insert_record(params) do
    %AuthProvider{}
    |> AuthProvider.changeset(params)
    |> Repo.insert()
  end
end
