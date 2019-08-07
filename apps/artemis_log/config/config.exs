use Mix.Config

config :artemis_log,
  ecto_repos: [ArtemisLog.Repo]

config :artemis_log, :actions,
  delete_event_logs_on_interval: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_DELETE_EVENT_LOGS_ON_INTERVAL_ENABLED"),
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_EVENT_LOGS_ON_INTERVAL_MAX_DAYS")
  ],
  delete_http_request_logs_on_interval: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_DELETE_HTTP_REQUEST_LOGS_ON_INTERVAL_ENABLED"),
    max_days: System.get_env("ARTEMIS_LOG_ACTION_DELETE_HTTP_REQUEST_LOGS_ON_INTERVAL_MAX_DAYS")
  ],
  subscribe_to_events: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_SUBSCRIBE_TO_EVENTS_ENABLED")
  ],
  subscribe_to_http_requests: [
    enabled: System.get_env("ARTEMIS_LOG_ACTION_SUBSCRIBE_TO_HTTP_REQUESTS_ENABLED")
  ]

import_config "#{Mix.env()}.exs"
