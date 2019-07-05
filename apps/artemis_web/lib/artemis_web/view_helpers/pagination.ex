defmodule ArtemisWeb.ViewHelper.Pagination do
  use Phoenix.HTML

  @doc """
  Generates pagination using scrivener_html
  """
  def render_pagination(conn, data, options \\ [])
  def render_pagination(_, %{total_pages: total_pages}, _) when total_pages == 1, do: nil

  def render_pagination(conn, data, options) do
    args = Keyword.get(options, :args, [])

    params =
      options
      |> Keyword.get(:params, conn.query_params)
      |> Artemis.Helpers.keys_to_atoms()
      |> Map.delete(:page)
      |> Enum.into([])

    Phoenix.View.render(ArtemisWeb.LayoutView, "pagination.html", args: args, conn: conn, data: data, params: params)
  end
end
