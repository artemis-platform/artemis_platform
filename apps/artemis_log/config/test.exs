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
  port: System.get_env("ARTEMIS_LOG_POSTGRES_PORT"),
  ssl: Enum.member?(["true", "\"true\""], System.get_env("ARTEMIS_LOG_POSTGRES_SSL_ENABLED")),
  pool: Ecto.Adapters.SQL.Sandbox

config :artemis_log, :actions,
  delete_event_logs_on_interval: [
    enabled: "false",
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_EVENT_LOGS_ON_INTERVAL_MAX_DAYS")
  ],
  delete_http_request_logs_on_interval: [
    enabled: "false",
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_HTTP_REQUEST_LOGS_ON_INTERVAL_MAX_DAYS")
  ],
  subscribe_to_events: [
    enabled: "false"
  ],
  subscribe_to_http_requests: [
    enabled: "false"
  ]
