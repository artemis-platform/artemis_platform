defmodule Artemis.AnonymizeUser do
  use Artemis.Context

  alias Artemis.GetUser
  alias Artemis.UpdateUser

  def call!(id, user) do
    case call(id, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error anonymizing user")
      {:ok, result} -> result
    end
  end

  def call(id, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> anonymize_record(user)
      |> Event.broadcast("user:anonymized", user)
    end)
  end

  defp get_record(%{id: id}, user), do: get_record(id, user)
  defp get_record(id, user), do: GetUser.call(id, user)

  defp anonymize_record(nil, _user), do: {:error, "Record not found"}

  defp anonymize_record(record, user) do
    uid = Artemis.Helpers.UUID.encode(record.id)

    params = %{
      email: "anonymized-user-#{uid}@noreply.ibm.com",
      first_name: nil,
      last_name: nil,
      name: "Anonymized User #{uid}"
    }

    UpdateUser.call(record, params, user)
  end
end
