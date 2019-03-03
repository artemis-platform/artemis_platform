defmodule AtlasWeb.SearchView do
  use AtlasWeb, :view

  alias AtlasWeb.Router.Helpers, as: Routes

  @search_links %{
    "features" => &Routes.feature_path/3,
    "permissions" => &Routes.permission_path/3,
    "roles" => &Routes.role_path/3,
    "users" => &Routes.user_path/3
  }

  def search_results?(%{total_entries: total_entries}), do: total_entries > 0
  def search_results?(data) do
    Enum.any?(data, fn ({_, resource}) ->
      Map.get(resource, :total_entries) > 0
    end)
  end

  def search_anchor(key), do: "anchor-#{key}"

  def search_title(data) do
    Atlas.Helpers.titlecase(data)
  end

  def search_total(data) do
    Map.get(data, :total_entries)
  end

  def search_link(conn, key, data) do
    label = "View " <> search_matches_text(data)
    to = Map.get(@search_links, key).(conn, :index, current_query_params(conn))

    action(label, to: to)
  end

  def search_matches_text(data) do
    total = search_total(data)

    ngettext("%{total} Match", "%{total} Matches", total, total: total)
  end

  def search_entries(data) do
    data
    |> Map.get(:entries)
    |> Enum.map(&search_entry(&1))
  end

  defp search_entry(%Atlas.Feature{} = data) do
    %{
      title: data.slug,
      permission: "features:show",
      link: fn (conn) -> Routes.feature_path(conn, :show, data) end
    }
  end
  defp search_entry(%Atlas.Permission{} = data) do
    %{
      title: data.slug,
      permission: "permissions:show",
      link: fn (conn) -> Routes.permission_path(conn, :show, data) end
    }
  end
  defp search_entry(%Atlas.Role{} = data) do
    %{
      title: data.slug,
      permission: "roles:show",
      link: fn (conn) -> Routes.user_path(conn, :show, data) end
    }
  end
  defp search_entry(%Atlas.User{} = data) do
    %{
      title: data.name,
      permission: "users:show",
      link: fn (conn) -> Routes.user_path(conn, :show, data) end
    }
  end

  def search_entries_total(data) do
    data
    |> search_entries()
    |> length()
  end
end
