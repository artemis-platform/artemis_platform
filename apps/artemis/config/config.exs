use Mix.Config

config :artemis,
  ecto_repos: [Artemis.Repo]

config :artemis, :actions,
  repo_delete_all: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_DELETE_ALL_ENABLED") == "true"
  ],
  repo_generate_filler_data: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_GENERATE_FILLER_DATA_ENABLED") == "true"
  ],
  repo_reset_on_interval: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_RESET_ON_INTERVAL_ENABLED") == "true",
    interval: System.get_env("ARTEMIS_ACTION_REPO_RESET_ON_INTERVAL_HOURS")
  ]

config :artemis, :users,
  root_user: %{
    name: System.get_env("ARTEMIS_ROOT_USER"),
    email: System.get_env("ARTEMIS_ROOT_EMAIL")
  },
  system_user: %{
    name: System.get_env("ARTEMIS_SYSTEM_USER"),
    email: System.get_env("ARTEMIS_SYSTEM_EMAIL")
  }

import_config "#{Mix.env()}.exs"
