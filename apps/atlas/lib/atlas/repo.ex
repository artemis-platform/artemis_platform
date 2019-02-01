defmodule Atlas.Repo do
  use Ecto.Repo,
    otp_app: :atlas,
    adapter: Ecto.Adapters.Postgres
end
