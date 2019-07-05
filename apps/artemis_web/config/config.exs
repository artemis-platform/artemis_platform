use Mix.Config

config :artemis_web,
  ecto_repos: [Artemis.Repo],
  generators: [context_app: :artemis],
  auth_providers: [enabled: System.get_env("ARTEMIS_WEB_ENABLED_AUTH_PROVIDERS")]

config :artemis_web, ArtemisWeb.Endpoint,
  url: [host: System.get_env("ARTEMIS_WEB_HOSTNAME")],
  secret_key_base: System.get_env("ARTEMIS_SECRET_KEY"),
  render_errors: [view: ArtemisWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ArtemisPubSub]

config :artemis_web, ArtemisWeb.Guardian,
  allowed_algos: ["HS512"],
  issuer: "artemis",
  ttl: {18, :hours},
  verify_issuer: true,
  secret_key: System.get_env("ARTEMIS_GUARDIAN_KEY")

config :scrivener_html,
  routes_helper: ArtemisWeb.Router.Helpers,
  view_style: :bootstrap

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []},
    system_user: {Ueberauth.Strategy.SystemUser, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("ARTEMIS_WEB_GITHUB_CLIENT_ID"),
  client_secret: System.get_env("ARTEMIS_WEB_GITHUB_CLIENT_SECRET")

import_config "#{Mix.env()}.exs"
