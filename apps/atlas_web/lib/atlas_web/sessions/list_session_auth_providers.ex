defmodule AtlasWeb.ListSessionAuthProviders do
  alias AtlasWeb.Router.Helpers, as: Routes

  def call(conn) do
    [
      %{title: "Local Provider", link: Routes.session_path(conn, :show, "local")}
    ]
  end
end
