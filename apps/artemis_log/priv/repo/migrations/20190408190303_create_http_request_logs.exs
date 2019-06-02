defmodule ArtemisLog.Repo.Migrations.CreateHttpRequestLogs do
  use Ecto.Migration

  def change do
    create table(:http_request_logs) do
      add :endpoint, :string
      add :node, :string
      add :path, :string
      add :query_string, :string
      add :session_id, :string
      add :user_id, :integer
      add :user_name, :string
      timestamps()
    end

    create index(:http_request_logs, :endpoint)
    create index(:http_request_logs, [:endpoint, :user_id])
    create index(:http_request_logs, [:endpoint, :user_name])
    create index(:http_request_logs, :node)
    create index(:http_request_logs, :path)
    create index(:http_request_logs, :session_id)
    create index(:http_request_logs, :user_id)
    create index(:http_request_logs, :user_name)
    create index(:http_request_logs, [:user_id, :session_id])
    create index(:http_request_logs, [:user_name, :session_id])
  end
end
