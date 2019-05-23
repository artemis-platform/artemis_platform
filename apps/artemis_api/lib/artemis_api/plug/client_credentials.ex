defmodule ArtemisApi.Plug.ClientCredentials do
  @moduledoc """
  Checks for OAuth2 Client Credentials passed in request headers. Supports:

    Authorization: Basic base64encoded(<client_id>:<client_password>)
    Authorization: Basic <client_id>:<client_password>

  If a matching header is not found, pass `conn` to next phase.

  If a matching header is found, lookup user by credentials, create a token,
  and replace current `Authorization` header with the user token.
  """

  @behaviour Plug

  import Plug.Conn

  alias Artemis.GetSystemUser
  alias Artemis.GetUser
  alias ArtemisApi.CreateSession

  def init(opts), do: opts

  def call(conn, _) do
    with {:ok, credentials} <- read_basic_authorization_header(conn),
         {:ok, credentials} <- decode_credentials(credentials),
         {:ok, client_key, client_secret} <- get_credential_parts(credentials),
         {:ok, user} <- get_user(client_key, client_secret),
         {:ok, session} <- CreateSession.call(user),
         {:ok, conn} <- remove_basic_auth_header(conn),
         {:ok, conn} <- add_bearer_auth_header(conn, session) do
      conn
    else
      _ -> conn
    end
  end

  defp read_basic_authorization_header(conn) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> credentials] -> {:ok, credentials}
      ["basic " <> credentials] -> {:ok, credentials}
      ["Basic: " <> credentials] -> {:ok, credentials}
      ["basic: " <> credentials] -> {:ok, credentials}
      _ -> {:skip, :authorization_basic_header_not_present}
    end
  end

  defp decode_credentials(credentials) when is_bitstring(credentials) do
    case String.contains?(credentials, ":") do
      true -> {:ok, credentials}
      false -> Base.decode64(credentials, ignore: :whitespace)
    end
  end

  defp decode_credentials(_), do: {:skip, :credentials_not_readable}

  defp get_credential_parts(credentials) when is_bitstring(credentials) do
    [client_key, client_secret] = String.split(credentials, ":")

    {:ok, client_key, client_secret}
  rescue
    _ -> {:skip, :credential_parts_unreadable}
  end

  defp get_credential_parts(_), do: {:skip, :credential_parts_not_present}

  defp get_user(client_key, client_secret) do
    system_user = GetSystemUser.call!()
    credentials = [client_key: client_key, client_secret: client_secret]

    case GetUser.call(credentials, system_user) do
      nil -> {:error, "User not found"}
      user -> {:ok, user}
    end
  end

  defp remove_basic_auth_header(conn) do
    {:ok, delete_req_header(conn, "authorization")}
  end

  defp add_bearer_auth_header(conn, %{token: token}) do
    {:ok, put_req_header(conn, "authorization", "Bearer #{token}")}
  end
end
