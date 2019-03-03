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

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :artemis_api, ArtemisApi.Endpoint,
  http: [port: 4002],
  server: false
