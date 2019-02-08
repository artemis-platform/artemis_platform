defmodule AtlasApi.GetUserByAuthProvider do
  alias Atlas.GetUser

  def call(%{provider: provider} = params) do
    case provider do
      "client-credentials" -> get_from_client_credentials(params)
      _ -> {:error, "Error provider not supported"}
    end
  end

  defp get_from_client_credentials(%{client_key: key, client_secret: secret}) do
    case GetUser.call(client_key: key, client_secret: secret) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end
end
