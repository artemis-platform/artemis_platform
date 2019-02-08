use Mix.Config

config :atlas_api,
  ecto_repos: [Atlas.Repo],
  generators: [context_app: :atlas],
  namespace: AtlasApi,
  release_branch: System.cmd("git",["rev-parse","--abbrev-ref","HEAD"]) |> elem(0) |> String.trim(),
  release_hash: System.cmd("git",["rev-parse","--short","HEAD"]) |> elem(0) |> String.trim()

config :atlas_api, AtlasApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("ATLAS_SECRET_KEY_BASE"),
  render_errors: [view: AtlasApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: AtlasPubSub]

config :atlas_api, AtlasApi.Guardian,
  allowed_algos: ["HS512"],
  issuer: "atlas",
  ttl: { 18, :hours },
  verify_issuer: true,
  secret_key: System.get_env("ATLAS_GUARDIAN_KEY")

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:request_id]

config :oauth2,
  warn_missing_serializer: false,
  serializers: %{
    "application/vnd.api+json" => Poison
  }

import_config "#{Mix.env}.exs"
