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

config :atlas_amqp, :connection,
  host: System.get_env("ATLAS_AMQP_RABBITMQ_HOST"),
  port: System.get_env("ATLAS_AMQP_RABBITMQ_PORT"),
  username: System.get_env("ATLAS_AMQP_RABBITMQ_USER"),
  password: System.get_env("ATLAS_AMQP_RABBITMQ_PASS"),
  virtual_host: System.get_env("ATLAS_AMQP_RABBITMQ_VIRTUAL_HOST"),
  ssl_options: [
    enabled: System.get_env("ATLAS_AMQP_RABBITMQ_SSL_ENABLED"),
    verify: :"#{System.get_env("ATLAS_AMQP_RABBITMQ_SSL_VERIFY")}",
    keyfile: to_charlist(System.get_env("ATLAS_AMQP_RABBITMQ_SSL_KEYFILE")),
    certfile: to_charlist(System.get_env("ATLAS_AMQP_RABBITMQ_SSL_CERTFILE")),
    cacertfile: to_charlist(System.get_env("ATLAS_AMQP_RABBITMQ_SSL_CACERTFILE"))
  ]
