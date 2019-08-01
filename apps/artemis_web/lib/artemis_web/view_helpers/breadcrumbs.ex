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
        |> get_title()

      path =
        sections
        |> Enum.take(index + 1)
        |> Enum.join("/")

      [title, "/#{path}"]
    end)
  end

  defp get_title(value) do
    case Map.get(get_custom_titles(), value, :not_found) do
      :not_found -> pretty_print(value)
      custom_title -> custom_title
    end
  end

  defp get_custom_titles() do
    :artemis_web
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.get(:custom_titles)
  end

  defp pretty_print(value) do
    value
    |> String.replace("-", " ")
    |> String.replace("_", " ")
    |> Artemis.Helpers.titlecase()
  end
end
