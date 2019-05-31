use Mix.Config

config :artemis_log,
  ecto_repos: [ArtemisLog.Repo],
  subscribe_to_events: System.get_env("ARTEMIS_LOG_SUBSCRIBE_TO_EVENTS") == "true",
  subscribe_to_http_requests: System.get_env("ARTEMIS_LOG_SUBSCRIBE_TO_HTTP_REQUESTS") == "true"

import_config "#{Mix.env()}.exs"
