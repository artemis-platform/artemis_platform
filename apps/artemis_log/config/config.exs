use Mix.Config

config :artemis_log,
  ecto_repos: [ArtemisLog.Repo]

import_config "#{Mix.env()}.exs"
