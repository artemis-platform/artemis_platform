defmodule ArtemisLog.Repo.Migrations.CreateEventLogs do
  use Ecto.Migration

  def change do
    create table(:event_logs) do
      add :action, :string
      add :meta, :map
      add :user_id, :integer
      add :user_name, :string
      timestamps()
    end

    create index(:event_logs, :action)
    create index(:event_logs, [:action, :user_id])
    create index(:event_logs, [:action, :user_name])
    create index(:event_logs, :user_id)
    create index(:event_logs, :user_name)

    execute "CREATE INDEX index_event_logs_meta ON event_logs USING gin(meta jsonb_path_ops);"
  end
end
