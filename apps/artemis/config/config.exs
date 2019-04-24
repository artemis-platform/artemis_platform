use Mix.Config

config :artemis,
  ecto_repos: [Artemis.Repo],
  root_user: %{
    name: {:system, "ARTEMIS_ROOT_USER"},
    email: {:system, "ARTEMIS_ROOT_EMAIL"}
  },
  system_user: %{
    name: {:system, "ARTEMIS_SYSTEM_USER"},
    email: {:system, "ARTEMIS_SYSTEM_EMAIL"}
  }

import_config "#{Mix.env()}.exs"
