defmodule ArtemisWeb.LayoutHelpers do
  @moduledoc """
  Convenience functions for common layout elements
  """

  use Phoenix.HTML

  @doc """
  Returns existing query params as a Keyword list
  """
  def current_query_params(conn) do
    Enum.into(conn.query_params, [])
  end

  @doc """
  Generates an action tag.

  Type of tag is determined by the `method`:

    GET: Anchor
    POST / PUT / PATCH / DELETE: Button (with CSRF token)

  Unless specified, the `method` value defaults to `GET`.

  Custom options:

    :color <String>
    :size <String>

  All other options are passed directly to the `Phoenix.HTML` function.
  """
  def action(title, options \\ []) do
    color = Keyword.get(options, :color, "basic")
    size = Keyword.get(options, :size, "small")
    method = Keyword.get(options, :method, "get")

    tag_options = options
      |> Enum.into(%{})
      |> Map.put(:class, "button ui #{size} #{color}")
      |> Enum.into([])

    if method == "get" do
      link(title, tag_options)
    else
      button(title, tag_options)
    end
  end

  @doc """
  Generates pagination using scrivener_html
  """
  def render_pagination(conn, data, options \\ [])
  def render_pagination(_, %{total_pages: total_pages}, _) when total_pages == 1, do: nil
  def render_pagination(conn, data, options) do
    args = Keyword.get(options, :args, [])
    params = options
      |> Keyword.get(:params, conn.query_params)
      |> Artemis.Helpers.keys_to_atoms()
      |> Map.delete(:page)
      |> Enum.into([])

    Phoenix.View.render(ArtemisWeb.LayoutView, "pagination.html", args: args, conn: conn, data: data, params: params)
  end

  @doc """
  Generates empty table row if no records match
  """
  def render_table_row_if_empty(records, options \\ [])
  def render_table_row_if_empty(records, options) when length(records) == 0 do
    message = Keyword.get(options, :message, "No records found")

    Phoenix.View.render(ArtemisWeb.LayoutView, "table_row_if_empty.html", message: message)
  end
  def render_table_row_if_empty(_records, _options), do: nil

  @doc """
  Generates search form
  """
  def render_search(conn) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "search.html", conn: conn)
  end

  @doc """
  Generates breadcrumbs from current URL
  """
  def render_breadcrumbs(conn) do
    path_sections = conn
      |> Map.get(:request_path)
      |> String.split("/", trim: true)

    breadcrumbs = get_root_breadcrumb() ++ get_breadcrumbs(path_sections)

    Phoenix.View.render(ArtemisWeb.LayoutView, "breadcrumbs.html", breadcrumbs: breadcrumbs)
  end

  defp get_root_breadcrumb, do: [["Home", "/"]]

  defp get_breadcrumbs(sections) when sections == [], do: []
  defp get_breadcrumbs(sections) do
    range = Range.new(0, length(sections) - 1)

    Enum.map(range, fn (index) ->
      title = sections
        |> Enum.at(index)
        |> String.capitalize

      path = sections
        |> Enum.take(index + 1)
        |> Enum.join("/")

      [title, "/#{path}"]
    end)
  end

  @doc """
  Generates a notification
  """
  def render_notification(type, params \\ []) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "notification_#{type}.html", params)
  end

  @doc """
  Generates flash notifications
  """
  def render_flash_notifications(conn) do
    Phoenix.View.render(ArtemisWeb.LayoutView, "flash_notifications.html", conn: conn)
  end
end
