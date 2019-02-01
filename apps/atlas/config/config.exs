use Mix.Config

config :atlas,
  ecto_repos: [Atlas.Repo],
  root_user: %{
    name: System.get_env("ATLAS_ROOT_USER"),
    email: System.get_env("ATLAS_ROOT_EMAIL")
  }

import_config "#{Mix.env()}.exs"
