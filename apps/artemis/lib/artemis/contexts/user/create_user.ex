defmodule Artemis.CreateUser do
  use Artemis.Context
  use Assoc.Updater, repo: Artemis.Repo

  alias Artemis.Repo
  alias Artemis.User

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating user")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    params = default_params(params)

    with_transaction(fn ->
      params
      |> insert_record()
      |> update_associations(params)
      |> Event.broadcast("user:created", user)
    end)
  end

  defp default_params(params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put("client_key", Artemis.Helpers.random_string(30))
    |> Map.put("client_secret", Artemis.Helpers.random_string(100))
  end

  defp insert_record(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end
end
