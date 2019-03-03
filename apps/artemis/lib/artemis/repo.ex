defmodule Artemis.Repo do
  use Ecto.Repo,
    otp_app: :artemis,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
