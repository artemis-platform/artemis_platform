defmodule AtlasWeb.HomeController do
  use AtlasWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
