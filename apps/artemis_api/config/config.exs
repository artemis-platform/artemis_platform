use Mix.Config

config :artemis_api,
  ecto_repos: [Artemis.Repo],
  generators: [context_app: :artemis],
  namespace: ArtemisApi,
  release_branch: System.cmd("git",["rev-parse","--abbrev-ref","HEAD"]) |> elem(0) |> String.trim(),
  release_hash: System.cmd("git",["rev-parse","--short","HEAD"]) |> elem(0) |> String.trim()

config :artemis_api, ArtemisApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("ARTEMIS_SECRET_KEY"),
  render_errors: [view: ArtemisApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: ArtemisPubSub]

config :artemis_api, ArtemisApi.Guardian,
  allowed_algos: ["HS512"],
  issuer: "artemis",
  ttl: { 18, :hours },
  verify_issuer: true,
  secret_key: System.get_env("ARTEMIS_GUARDIAN_KEY")

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
