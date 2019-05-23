defmodule ArtemisWeb.AuthView do
  use ArtemisWeb, :view

  def list_auth_providers(conn) do
    state = Map.get(conn.query_params, "redirect")

    available_providers = %{
      "github" => %{
        title: "Log in with GitHub",
        color: "blue",
        link: Routes.auth_path(conn, :request, "github", state: state)
      },
      "system_user" => %{
        title: "Log in as System User",
        color: "red",
        link: Routes.auth_path(conn, :callback, "system_user", state: state)
      }
    }

    enabled_providers =
      :artemis_web
      |> Application.get_env(:auth_providers, [])
      |> Keyword.get(:enabled, "")
      |> String.split(",")

    available_providers
    |> Map.take(enabled_providers)
    |> Enum.map(fn {_key, value} -> value end)
  end
end
