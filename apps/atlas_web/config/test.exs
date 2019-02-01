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

config :atlas_web, AtlasWeb.Endpoint,
  http: [port: 4002],
  server: false
