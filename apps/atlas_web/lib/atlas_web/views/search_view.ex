defmodule AtlasWeb.SearchView do
  use AtlasWeb, :view

  alias AtlasWeb.Router.Helpers, as: Routes

  def search_entries(data) do
    Enum.reduce(data, [], fn ({_, value}, acc) ->
      entries = value
        |> Map.get(:entries)
        |> Enum.map(&search_entry(&1))

      Enum.concat(acc, entries)
    end)
  end

  defp search_entry(%Atlas.User{} = data) do
    %{
      title: data.name,
      permission: "users:show",
      link: fn (conn) -> Routes.user_path(conn, :show, data) end
    }
  end
end
