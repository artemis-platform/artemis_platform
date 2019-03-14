defmodule ArtemisWeb.LayoutView do
  use ArtemisWeb, :view

  import Scrivener.HTML

  def render_primary_nav(conn, user) do
    nav_items = get_nav_items_for_current_user(user)
    links = Enum.map(nav_items, fn ({section, items}) ->
      label = section
      path = items
        |> hd
        |> Keyword.get(:path)

      content_tag(:li) do
        link(label, to: path.(conn))
      end
    end)

    case links == [] do
      true -> nil
      false -> content_tag(:ul, links)
    end
  end

  def get_nav_items_for_current_user(user) do
    Enum.reduce(nav_links(), [], fn ({section, potential_items}, acc) ->
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

  def nav_links do
    Enum.reverse([
      "Event Log": [
        [
          label: "Event Log",
          path: &Routes.event_log_path(&1, :index),
          verify: &has?(&1, "event-logs:list")
        ]
      ],
      "Features": [
        [
          label: "List Features",
          path: &Routes.feature_path(&1, :index),
          verify: &has?(&1, "features:list")
        ],
        [
          label: "Create New Feature",
          path: &Routes.feature_path(&1, :new),
          verify: &has?(&1, "features:create")
        ]
      ],
      "Permissions": [
        [
          label: "List Permissions",
          path: &Routes.permission_path(&1, :index),
          verify: &has?(&1, "permissions:list")
        ],
        [
          label: "Create New Permission",
          path: &Routes.permission_path(&1, :new),
          verify: &has?(&1, "permissions:create")
        ]
      ],
      "Roles": [
        [
          label: "List Roles",
          path: &Routes.role_path(&1, :index),
          verify: &has?(&1, "roles:list")
        ],
        [
          label: "Create New Role",
          path: &Routes.role_path(&1, :new),
          verify: &has?(&1, "roles:create")
        ]
      ],
      "Users": [
        [
          label: "List Users",
          path: &Routes.user_path(&1, :index),
          verify: &has?(&1, "users:list")
        ],
        [
          label: "Create New User",
          path: &Routes.user_path(&1, :new),
          verify: &has?(&1, "users:create")
        ]
      ]
    ])
  end
end
