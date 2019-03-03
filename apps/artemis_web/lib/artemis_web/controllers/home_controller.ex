defmodule ArtemisWeb.HomeController do
  use ArtemisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
