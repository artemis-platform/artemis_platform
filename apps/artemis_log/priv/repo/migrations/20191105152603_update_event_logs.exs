defmodule ArtemisLog.Repo.Migrations.UpdateEventLogs do
  use Ecto.Migration

  def change do
    rename table(:event_logs), :meta, to: :data

    alter table(:event_logs) do
      add :meta, :map
    end
  end
end
