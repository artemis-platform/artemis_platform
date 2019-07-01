defmodule ArtemisApi.GetUserByAuthProvider do
  alias Artemis.GetUser
  alias Artemis.GetSystemUser
  alias Artemis.UpdateUser

  def call(%{provider: provider} = params) do
    case provider do
      "client-credentials" -> get_from_client_credentials(params)
      _ -> {:error, "Error provider not supported"}
    end
  end

  defp get_from_client_credentials(%{client_key: key, client_secret: secret}) do
    system_user = GetSystemUser.call!()

    params = [
      client_key: key,
      client_secret: secret
    ]

    case GetUser.call(params, system_user) do
      nil -> {:error, "User not found"}
      user -> update_user(user, system_user)
    end
  end

  defp update_user(user, system_user) do
    params = %{
      last_log_in_at: DateTime.to_string(DateTime.utc_now()),
      session_id: Artemis.Helpers.UUID.call()
    }

    UpdateUser.call(user.id, params, system_user)
  end
end
