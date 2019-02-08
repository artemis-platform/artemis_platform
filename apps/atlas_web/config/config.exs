use Mix.Config

config :atlas_web,
  ecto_repos: [Atlas.Repo],
  generators: [context_app: :atlas]

config :atlas_web, AtlasWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("ATLAS_SECRET_KEY"),
  render_errors: [view: AtlasWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AtlasPubSub]

config :atlas_web, AtlasWeb.Guardian,
  allowed_algos: ["HS512"],
  issuer: "atlas",
  ttl: {18, :hours},
  verify_issuer: true,
  secret_key: System.get_env("ATLAS_GUARDIAN_KEY")

import_config "#{Mix.env()}.exs"
