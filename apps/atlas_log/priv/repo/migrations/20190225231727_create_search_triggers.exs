defmodule AtlasLog.Repo.Migrations.CreateSearchTriggers do
  use Ecto.Migration

  @moduledoc """
  Full Text Search

  See comments on each section for details on creating searchable fields.
  Repeat for each table to be included in the full text search.
  """

  def up do
    # 1. Create Search Data Column
    alter table(:event_logs) do
      add :tsv_search, :tsvector
    end

    # 2. Create Search Data Index
    create index(:event_logs, [:tsv_search], name: :features_search_vector, using: "GIN")

    # 3. Define a Coalesce Function
    execute("""
      CREATE FUNCTION create_search_data_event_logs() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.action, ' ') || ' ' ||
            coalesce(new.user_name, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

    # 4. Trigger the Function
    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON event_logs FOR EACH ROW EXECUTE PROCEDURE create_search_data_event_logs();
    """)
  end

  def down do
    # 1. Remove Triggers
    execute("drop function create_search_data_event_logs();")

    # 2. Remove Functions
    execute("drop trigger tsvectorupdate on event_logs;")

    # 3. Remove Indexes
    drop index(:event_logs, [:tsv_search])

    # 4. Remove Columns
    alter table(:event_logs) do
      remove :tsv_search
    end
  end
end
