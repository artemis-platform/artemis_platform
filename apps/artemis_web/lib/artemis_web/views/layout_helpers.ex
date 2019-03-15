defmodule ArtemisWeb.LayoutHelpers do
  use Phoenix.HTML

  import ArtemisWeb.LayoutData

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

  @doc """
  Render Data Table

  Example:

    <%=
      render_data_table(
        @conn,
        @customers,
        allowed_columns: allowed_columns(),
        default_columns: ["name", "slug", "actions"]
      )
    %>

  Options:

    allowed_columns: map of allowed columns
    default_columns: list of strings

  ## Features

  ### Column Ordering

  The `columns` query param can be used to define a custom order to table
  columns. For example, the default columns might be:

    Name | Slug | Actions

  By passing in the query param `?columns=status,name,address` the table
  will transform to show:

    Status | Name | Address

  This enables custom reporting in a standard and repeatable way across the
  application. Since query params are used to define the columns, any reports a
  user creates can be revisited using the same URL. Which in turn, also makes
  it easy to share with others.

  ### Table Export

  Custom exporters can be defined for any format, like `html`, `json`, `csv`,
  `xls`, or `pdf`. There's no conventions to learn or magic. As documented below,
  standard Elixir and Phoenix code can be used to define and write custom
  exporters in any format.

  ## Options

  The goal of the data table is to be extensible without introducing new
  data table specific conventions. Instead, enable extension using standard
  Elixir and Phoenix calls.

  ### Allowed Columns

  The value for `allowed_columns` should be a map. A complete example may look like:

    %{
      "name" => [
        label: fn (_conn) -> "Name" end,
        value: fn (_conn, row) -> row.name end,
      ],
      "slug" => [
        label: fn (_conn) -> "Slug" end,
        value: fn (_conn, row) -> row.slug end,
      ]
    }

  The key for each entry should be a URI friendly slug. It is used to match
  against the `columns` query param.

  The value for each entry is a keyword list. It must define a `label` and
  `value` function.

  The `label` function is used in column headings. It takes one argument, the
  `conn` struct. The most common return will be a simple bitstring, but
  the `conn` is included for more advanced usage, for instance creating an
  anchor link.

  The `value` function is used for the column value. It takes two arguments,
  the `conn` struct and the `row` value. The most common return will be calling
  an attribute on the row value, for instance `data.name`. The `conn` value is
  included for more advanced usage.

  #### Support for Different Content Types / Formats

  The required `label` and `value` functions should return simple values, like
  bitstrings, integers, and floats.

  Format specific values, such as HTML tags, should be defined in format
  specific keys. For instance:

      "name" => [
        label: fn (_conn) -> "Name" end,
        value: fn (_conn, row) -> row.name end,
        value_html: fn (conn, row) ->
          link(row.name, to: Routes.permission_path(conn, :show, row))
        end
      ]

  The data table function will first search for `label_<format>` and
  `value_<format>` keys. E.g. a standard `html` request would search for
  `label_html` and `value_html`. And in turn, a request for `csv` content type
  would search for `label_csv` and `value_csv`. If format specific keys are not
  found, the require `label` and `value` keys will be used as a fallback.

  ### Default Columns

  The default columns option should be a list of bitstrings, each corresponding
  to a key defined in the `allowed_columns` map.

    default_columns: ["name", "slug"]

  """
  def render_data_table(conn, data, options \\ []) do
    format = Phoenix.Controller.get_format(conn)
    columns = get_data_table_columns(conn, options)
    params = [
      columns: columns,
      conn: conn,
      data: data
    ]

    Phoenix.View.render(ArtemisWeb.LayoutView, "data_table.#{format}", params)
  end

  @doc """
  Compares the `?columns=` query param value against the `allowed_columns`. If
  the query param is not set, compares the `default_columns` value instead.
  Returns a map of matching keys in `allowed_columns`.
  """
  def get_data_table_columns(conn, options) do
    allowed_columns = Keyword.get(options, :allowed_columns, [])
    requested_columns = case Map.get(conn.query_params, "columns") do
      nil -> Keyword.get(options, :default_columns, [])
      columns -> String.split(columns, ",")
    end

    filtered = Enum.reduce(requested_columns, [], fn (key, acc) ->
      case Map.get(allowed_columns, key) do
        nil -> acc
        column -> [column|acc]
      end
    end)

    Enum.reverse(filtered)
  end

  @doc """
  Renders the label for a data center column.
  """
  def render_data_table_label(conn, column, format) do
    key = String.to_atom("label_#{format}")
    default = Keyword.fetch!(column, :label)
    render = Keyword.get(column, key, default)

    render.(conn)
  end

  @doc """
  Renders the row value for a data center column.
  """
  def render_data_table_value(conn, column, row, format) do
    key = String.to_atom("value_#{format}")
    default = Keyword.fetch!(column, :value)
    render = Keyword.get(column, key, default)

    render.(conn, row)
  end
end
