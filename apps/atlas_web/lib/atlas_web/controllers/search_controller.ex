defmodule AtlasWeb.SearchController do
  use AtlasWeb, :controller

  alias Atlas.Search

  def index(conn, params) do
    results = Search.call(params, current_user(conn))

    render(conn, "index.html", results: results)
  end
end
