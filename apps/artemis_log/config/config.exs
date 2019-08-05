use Mix.Config

config :artemis_log,
  ecto_repos: [ArtemisLog.Repo],
  subscribe_to_events: System.get_env("ARTEMIS_LOG_SUBSCRIBE_TO_EVENTS") == "true",
  subscribe_to_http_requests: System.get_env("ARTEMIS_LOG_SUBSCRIBE_TO_HTTP_REQUESTS") == "true"

config :artemis_log, :actions,
  delete_event_logs_on_interval: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_DELETE_EVENT_LOGS_ON_INTERVAL_ENABLED"),
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_EVENT_LOGS_ON_INTERVAL_MAX_DAYS")
  ],
  delete_http_request_logs_on_interval: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_DELETE_HTTP_REQUEST_LOGS_ON_INTERVAL_ENABLED"),
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_HTTP_REQUEST_LOGS_ON_INTERVAL_MAX_DAYS")
  ]

import_config "#{Mix.env()}.exs"
