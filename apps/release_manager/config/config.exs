use Mix.Config

config :release_manager, apps: [
  atlas: Atlas.Repo,
  atlas_log: AtlasLog.Repo
]
