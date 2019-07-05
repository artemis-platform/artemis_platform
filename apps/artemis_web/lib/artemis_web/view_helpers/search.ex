defmodule ArtemisWeb.ViewHelper.Search do
  use Phoenix.HTML

  @doc """
  Generates search form
  """
  def render_search(conn, options \\ []) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "search.html", conn: conn, options: options)
  end
end
