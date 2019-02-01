# Since configuration is shared in umbrella projects, this file
# should only configure the :atlas application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :atlas,
  ecto_repos: [Atlas.Repo]

import_config "#{Mix.env()}.exs"
