defmodule ArtemisWeb.ViewHelper.Breadcrumbs do
  use Phoenix.HTML

  @doc """
  Generates breadcrumbs from current URL
  """
  def render_breadcrumbs(conn) do
    path_sections =
      conn
      |> Map.get(:request_path)
      |> String.split("/", trim: true)

    breadcrumbs = get_root_breadcrumb() ++ get_breadcrumbs(path_sections)

    Phoenix.View.render(ArtemisWeb.LayoutView, "breadcrumbs.html", breadcrumbs: breadcrumbs)
  end

  defp get_root_breadcrumb, do: [["Home", "/"]]

  defp get_breadcrumbs(sections) when sections == [], do: []

  defp get_breadcrumbs(sections) do
    range = Range.new(0, length(sections) - 1)

    Enum.map(range, fn index ->
      title =
        sections
        |> Enum.at(index)
        |> String.replace("-", " ")
        |> Artemis.Helpers.titlecase()

      path =
        sections
        |> Enum.take(index + 1)
        |> Enum.join("/")

      [title, "/#{path}"]
    end)
  end
end
