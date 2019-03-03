defmodule ArtemisWeb.GetUserByAuthProvider do
  alias Artemis.CreateUser
  alias Artemis.GetSystemUser
  alias Artemis.GetUser
  alias Artemis.UpdateUser

  def call(%{"id" => provider} = _params) do
    case provider do
      "local" -> get_from_config()
      _ -> {:error, "Error provider not supported"}
    end
  end

  defp get_from_config do
    case Application.get_env(:artemis, :system_user) do
      nil -> {:error, "Error fetching data from provider"}
      user_data -> create_or_update_user(user_data.email, user_data)
    end
  end

  defp create_or_update_user(email, data) do
    system_user = GetSystemUser.call()

    case GetUser.call([email: email], system_user) do
      nil -> CreateUser.call(data, system_user)
      user -> UpdateUser.call(user.id, data, system_user)
    end
  end
end
