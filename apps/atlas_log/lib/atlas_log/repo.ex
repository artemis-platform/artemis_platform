defmodule AtlasLog.Repo do
  use Ecto.Repo,
    otp_app: :atlas_log,
    adapter: Ecto.Adapters.Postgres
end
