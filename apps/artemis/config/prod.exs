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

config :artemis, Artemis.Repo,
  username: {:system, "ARTEMIS_POSTGRES_USER"},
  password: {:system, "ARTEMIS_POSTGRES_PASS"},
  database: {:system, "ARTEMIS_POSTGRES_DB"},
  hostname: {:system, "ARTEMIS_POSTGRES_HOST"},
  pool_size: 10
