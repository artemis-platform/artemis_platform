# Since configuration is shared in umbrella projects, this file
# should only configure the :atlas_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :atlas_web,
  ecto_repos: [Atlas.Repo],
  generators: [context_app: :atlas]

# Configures the endpoint
config :atlas_web, AtlasWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JcJCFkvzfTjWLua+DN7BRfa2SrDOhfc/DureK1yzbo6AGq+iZxrKEaA/mZkU29/f",
  render_errors: [view: AtlasWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AtlasWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
