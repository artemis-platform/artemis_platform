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
  server: true # Enable for use in browser testing with hound

config :hound,
  browser: "chrome_headless",
  driver: "chrome_driver"
