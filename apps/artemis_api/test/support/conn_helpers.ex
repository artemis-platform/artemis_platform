defmodule ArtemisApi.ConnHelpers do
  alias ArtemisApi.Mock

  def sign_in(conn, user \\ Mock.system_user()) do
    {:ok, token, _} = ArtemisApi.Guardian.encode_and_sign(user, %{}, token_type: :access)

    Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)
  end

  def sign_in_with_client_credentials(conn, user \\ Mock.system_user()) do
    basic = Base.encode64("#{user.client_key}:#{user.client_secret}")

    Plug.Conn.put_req_header(conn, "authorization", "basic: " <> basic)
  end
end
