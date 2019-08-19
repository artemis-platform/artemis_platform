defmodule ArtemisLog.Repo do
  use Ecto.Repo,
    otp_app: :artemis_log,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  def init(_type, static_config) do
    config_file = Application.fetch_env!(:artemis_log, ArtemisLog.Repo)

    ssl_enabled = Keyword.get(config_file, :ssl_enabled)
    ssl_enabled? = Enum.member?(["true", "\"true\""], ssl_enabled)

    dynamic_config = Keyword.put(static_config, :ssl, ssl_enabled?)

    {:ok, dynamic_config}
  end
end
