defmodule AtlasWeb.GetUserByAuthProvider do
  alias Atlas.CreateUser
  alias Atlas.GetRootUser
  alias Atlas.GetUser
  alias Atlas.UpdateUser

  def call(%{"id" => provider} = _params) do
    case provider do
      "local" -> get_from_config()
      _ -> {:error, "Error provider not supported"}
    end
  end

  defp get_from_config do
    case Application.get_env(:atlas, :root_user) do
      nil -> {:error, "Error fetching data from provider"}
      user_data -> create_or_update_user(user_data.email, user_data)
    end
  end

  defp create_or_update_user(email, data) do
    root_user = GetRootUser.call()

    case GetUser.call(email: email) do
      nil -> CreateUser.call(data, root_user)
      user -> UpdateUser.call(user.id, data, root_user)
    end
  end
end
