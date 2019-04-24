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
  username: {:system, "ARTEMIS_LOG_POSTGRES_USER"},
  password: {:system, "ARTEMIS_LOG_POSTGRES_PASS"},
  database: {:system, "ARTEMIS_LOG_POSTGRES_DB"},
  hostname: {:system, "ARTEMIS_LOG_POSTGRES_HOST"},
  pool_size: 10
