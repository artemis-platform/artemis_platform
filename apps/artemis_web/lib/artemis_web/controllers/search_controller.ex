defmodule ArtemisWeb.SearchController do
  use ArtemisWeb, :controller

  alias Artemis.Search

  def index(conn, params) do
    results = Search.call(params, current_user(conn))

    render(conn, "index.html", results: results)
  end
end
