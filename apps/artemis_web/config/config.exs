use Mix.Config

config :artemis_web,
  ecto_repos: [Artemis.Repo],
  generators: [context_app: :artemis]

config :artemis_web, ArtemisWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: {:system, "ARTEMIS_SECRET_KEY"},
  render_errors: [view: ArtemisWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ArtemisPubSub]

config :artemis_web, ArtemisWeb.Guardian,
  allowed_algos: ["HS512"],
  issuer: "artemis",
  ttl: {18, :hours},
  verify_issuer: true,
  secret_key: {:system, "ARTEMIS_GUARDIAN_KEY"}

config :scrivener_html,
  routes_helper: ArtemisWeb.Router.Helpers,
  view_style: :bootstrap

import_config "#{Mix.env()}.exs"
