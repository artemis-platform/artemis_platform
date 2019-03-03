use Mix.Config

config :release_manager, apps: [
  artemis: Artemis.Repo,
  artemis_log: ArtemisLog.Repo
]
