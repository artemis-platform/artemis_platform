use Mix.Config

config :atlas_log,
  ecto_repos: [AtlasLog.Repo]

import_config "#{Mix.env()}.exs"
