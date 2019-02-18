defmodule AtlasApi.ConnHelpers do
  alias AtlasApi.Mock

  def sign_in(conn, user \\ Mock.system_user()) do
    {:ok, token, _} = AtlasApi.Guardian.encode_and_sign(user, %{}, token_type: :access)

    Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)
  end
end
