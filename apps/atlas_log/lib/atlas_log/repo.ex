defmodule AtlasLog.Repo do
  use Ecto.Repo,
    otp_app: :atlas_log,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
