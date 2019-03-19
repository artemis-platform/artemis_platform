defmodule ArtemisWeb.ViewHelper.Layout do
  use Phoenix.HTML

  import ArtemisWeb.ViewData.Layout

  @moduledoc """
  Convenience functions for common layout elements
  """

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
  def action(label, options \\ []) do
    color = Keyword.get(options, :color, "basic")
    size = Keyword.get(options, :size, "small")
    method = Keyword.get(options, :method, "get")

    tag_options = options
      |> Enum.into(%{})
      |> Map.put(:class, "button ui #{size} #{color}")
      |> Enum.into([])

    if method == "get" do
      link(label, tag_options)
    else
      button(label, tag_options)
    end
  end

  @doc """
  Generates export link with specified format
  """
  def export_path(conn, format) do
    query_params = conn
      |> Map.get(:query_params, %{})
      |> Map.put("_format", format)
    query_string = URI.encode_query(query_params)

    "#{conn.request_path}?#{query_string}"
  end

  @doc """
  Generates primary nav from nav items
  """
  def render_primary_nav(conn, user) do
    nav_items = nav_items_for_current_user(user)
    links = Enum.map(nav_items, fn ({section, items}) ->
      label = section
      path = items
        |> hd
        |> Keyword.get(:path)

      content_tag(:li) do
        link(label, to: path.(conn))
      end
    end)

    content_tag(:ul, links)
  end

  @doc """
  Generates footer nav from nav items
  """
  def render_footer_nav(conn, user) do
    nav_items = nav_items_for_current_user(user)
    sections = Enum.map(nav_items, fn ({section, items}) ->
      links = Enum.map(items, fn (item) ->
        label = Keyword.get(item, :label)
        path = Keyword.get(item, :path)

        content_tag(:li) do
          link(label, to: path.(conn))
        end
      end)

      content_tag(:div, class: "section") do
        [
          content_tag(:h5, section),
          content_tag(:ul, links)
        ]
      end
    end)

    case sections == [] do
      true ->
        nil
      false ->
        per_column = length(sections) / 3
          |> Float.ceil()
          |> trunc()
        chunked = Enum.chunk_every(sections, per_column)

        Enum.map(chunked, fn (sections) ->
          content_tag(:div, sections, class: "column")
        end)
    end
  end

  @doc """
  Filter nav items by current users permissions
  """
  def nav_items_for_current_user(user) do
    Enum.reduce(nav_items(), [], fn ({section, potential_items}, acc) ->
      verified_items = Enum.filter(potential_items, fn (item) ->
        verify = Keyword.get(item, :verify)

        verify.(user)
      end)

      case verified_items == [] do
        true -> acc
        false -> [{section, verified_items}|acc]
      end
    end)
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
        |> String.replace("-", " ")
        |> Artemis.Helpers.titlecase()

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
