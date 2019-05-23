defmodule ArtemisLog.Repo do
  use Ecto.Repo,
    otp_app: :artemis_log,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10
end
