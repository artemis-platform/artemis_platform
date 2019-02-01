use Mix.Config

# Set the log level
#
# The order from most information to least:
#
#   :debug
#   :info
#   :warn
#
config :logger, level: :info

config :atlas, Atlas.Repo,
  username: System.get_env("ATLAS_POSTGRES_USER"),
  password: System.get_env("ATLAS_POSTGRES_PASS"),
  database: System.get_env("ATLAS_POSTGRES_DB") <> "_test",
  hostname: System.get_env("ATLAS_POSTGRES_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox
