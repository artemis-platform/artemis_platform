defmodule ArtemisLog.Repo.Migrations.CreateEventLogs do
  use Ecto.Migration

  def change do
    create table(:event_logs) do
      add :action, :string
      add :meta, :map
      add :resource_id, :string
      add :resource_type, :string
      add :session_id, :string
      add :user_id, :integer
      add :user_name, :string
      timestamps()
    end

    create index(:event_logs, :action)
    create index(:event_logs, [:action, :session_id])
    create index(:event_logs, [:action, :user_id])
    create index(:event_logs, [:action, :user_name])
    create index(:event_logs, :resource_id)
    create index(:event_logs, :resource_type)
    create index(:event_logs, [:resource_id, :resource_type])
    create index(:event_logs, [:resource_type, :resource_id])
    create index(:event_logs, :session_id)
    create index(:event_logs, :user_id)
    create index(:event_logs, :user_name)
    create index(:event_logs, [:user_id, :session_id])
    create index(:event_logs, [:user_name, :session_id])

    execute "CREATE INDEX index_event_logs_meta ON event_logs USING gin(meta jsonb_path_ops);"
  end
end
