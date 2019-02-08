defmodule Atlas.CreateUser do
  use Atlas.Context
  use Assoc.Updater, repo: Atlas.Repo

  import Atlas.Helpers, only: [keys_to_strings: 2, random_string: 1]

  alias Atlas.Repo
  alias Atlas.User

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Atlas.Context.Error, "Error creating user")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn () ->
      params
      |> insert_record()
      |> update_associations(params)
      |> Event.broadcast("user:created", user)
    end)
  end

  defp insert_record(params) do
    params = params
      |> Map.put("client_key", random_string(30))
      |> Map.put("client_secret", random_string(100))
      |> keys_to_strings([])

    %User{}
    |> User.changeset(params)
    |> Repo.insert
  end
end
