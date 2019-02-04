defmodule AtlasWeb.ConnHelpers do
  alias Atlas.Repo
  alias Atlas.User

  def sign_in(conn, user \\ get_root_user()) do
    {:ok, token, _} = AtlasWeb.Guardian.encode_and_sign(user, %{}, token_type: :access)

    Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token)
  end

  defp get_root_user() do
    params = Application.fetch_env!(:atlas, :root_user)

    Repo.get_by(User, email: params.email)
  end
end
