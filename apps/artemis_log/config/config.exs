use Mix.Config

config :artemis_log,
  ecto_repos: [ArtemisLog.Repo],
  subscribe_to_events: true

import_config "#{Mix.env()}.exs"
