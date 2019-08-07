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

config :artemis, :actions,
  repo_delete_all: [enabled: "false"],
  repo_generate_filler_data: [enabled: "false"],
  repo_reset_on_interval: [enabled: "false"]

config :artemis, Artemis.Repo,
  username: System.get_env("ARTEMIS_POSTGRES_USER"),
  password: System.get_env("ARTEMIS_POSTGRES_PASS"),
  database: System.get_env("ARTEMIS_POSTGRES_DB") <> "_test",
  hostname: System.get_env("ARTEMIS_POSTGRES_HOST"),
  port: System.get_env("ARTEMIS_POSTGRES_PORT"),
  ssl: Enum.member?(["true", "\"true\""], System.get_env("ARTEMIS_POSTGRES_SSL_ENABLED")),
  pool: Ecto.Adapters.SQL.Sandbox
