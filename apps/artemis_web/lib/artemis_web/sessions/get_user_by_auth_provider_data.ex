defmodule ArtemisWeb.GetUserByAuthProviderData do
  require Logger

  alias Artemis.CreateAuthProvider
  alias Artemis.CreateUser
  alias Artemis.GetSystemUser
  alias Artemis.GetAuthProvider
  alias Artemis.GetRole
  alias Artemis.GetUser
  alias Artemis.UpdateAuthProvider
  alias Artemis.UpdateUser

  @default_role "default"

  def call(data, options \\ []) do
    case auth_provider_enabled?(data, options) do
      true -> get_user(data)
      false -> {:error, "Error auth provider not supported"}
    end
  end

  defp auth_provider_enabled?(_data, enable_all_providers: true), do: true

  defp auth_provider_enabled?(data, _options) do
    enabled_auth_providers =
      :artemis_web
      |> Application.get_env(:auth_providers, [])
      |> Keyword.get(:enabled, "")
      |> String.split(",")

    auth_provider =
      data
      |> Map.get(:provider)
      |> Artemis.Helpers.to_string()

    Enum.member?(enabled_auth_providers, auth_provider)
  end

  defp get_user(data) do
    system_user = GetSystemUser.call!()

    user_params = get_user_params(data)
    user = get_user(user_params, system_user)

    auth_provider_params = get_auth_provider_params(data, user_params)
    auth_provider = get_auth_provider(auth_provider_params, system_user)

    result =
      if auth_provider do
        update_auth_provider!(auth_provider, auth_provider_params, system_user)
        update_user!(auth_provider.user, user_params, system_user)
      else
        user_record = create_or_update_user!(user, user_params, system_user)
        create_auth_provider!(auth_provider_params, user_record, system_user)
        user_record
      end

    {:ok, result}
  rescue
    error ->
      Logger.debug("Get User by Auth Provider Data Error: " <> inspect(error))
      {:error, "Error processing auth provider data"}
  end

  # Helpers - User

  defp get_user_params(data) do
    data
    |> Map.get(:info, %{})
    |> Map.put(:last_log_in_at, DateTime.to_string(DateTime.utc_now()))
    |> Map.put(:session_id, Artemis.Helpers.UUID.call())
    |> Artemis.Helpers.deep_delete(:__struct__)
    |> Artemis.Helpers.keys_to_strings()
  end

  defp get_user(user_params, system_user) do
    user_params
    |> Map.take(["email"])
    |> Artemis.Helpers.keys_to_atoms()
    |> Enum.into([])
    |> GetUser.call(system_user)
  end

  defp create_or_update_user!(nil, user_params, system_user), do: create_user!(user_params, system_user)
  defp create_or_update_user!(record, user_params, system_user), do: update_user!(record, user_params, system_user)

  defp create_user!(user_params, system_user) do
    default_role = GetRole.call([slug: @default_role], system_user)

    user_params
    |> Map.put("user_roles", [%{"role_id" => default_role.id}])
    |> CreateUser.call!(system_user)
  end

  defp update_user!(user, user_params, system_user) do
    params = Map.take(user_params, ["last_log_in_at", "session_id"])

    UpdateUser.call!(user.id, params, system_user)
  end

  # Helpers - Auth Provider

  defp get_auth_provider_params(data, user_params) do
    provider_data =
      data
      |> Map.get(:extra, user_params)
      |> Artemis.Helpers.deep_delete(:__struct__)

    %{}
    |> Map.put(:data, provider_data)
    |> Map.put(:type, Artemis.Helpers.to_string(data.provider))
    |> Map.put(:uid, Artemis.Helpers.to_string(data.uid))
    |> Artemis.Helpers.keys_to_strings()
  end

  defp get_auth_provider(auth_provider_params, system_user) do
    auth_provider_params
    |> Map.take(["type", "uid"])
    |> Artemis.Helpers.keys_to_atoms()
    |> Enum.into([])
    |> GetAuthProvider.call(system_user)
  end

  defp create_auth_provider!(auth_provider_params, user, system_user) do
    auth_provider_params
    |> Map.put("user_id", user.id)
    |> CreateAuthProvider.call!(system_user)
  end

  defp update_auth_provider!(auth_provider, auth_provider_params, system_user) do
    UpdateAuthProvider.call!(auth_provider.id, auth_provider_params, system_user)
  end
end
