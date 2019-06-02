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

config :artemis_log, ArtemisLog.Repo,
  username: System.get_env("ARTEMIS_LOG_POSTGRES_USER"),
  password: System.get_env("ARTEMIS_LOG_POSTGRES_PASS"),
  database: System.get_env("ARTEMIS_LOG_POSTGRES_DB") <> "_test",
  hostname: System.get_env("ARTEMIS_LOG_POSTGRES_HOST"),
  pool: Ecto.Adapters.SQL.Sandbox

config :artemis_log,
  subscribe_to_events: false,
  subscribe_to_http_requests: false
