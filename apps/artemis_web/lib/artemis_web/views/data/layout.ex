defmodule ArtemisWeb.ViewData.Layout do
  import ArtemisWeb.UserAccess

  alias ArtemisWeb.Router.Helpers, as: Routes

  @moduledoc """
  Collection of modifiable layout data
  """

  @doc """
  List of possible nav items. Each entry should define:

  - label: user facing label for the nav item
  - path: function that takes `conn` as the first argument and returns a string path
  - verify: function that takes the `current_user` as the first argument and returns a boolean
  """
  def nav_items do
    Enum.reverse([
      "Event Log": [
        [
          label: "View Event Log",
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
