defmodule Atlas.Repo.Migrations.CreateSearchTriggers do
  use Ecto.Migration

  @moduledoc """
  Full Text Search

  See comments on each section for details on creating searchable fields.
  Repeat for each table to be included in the full text search.
  """

  def up do
    # 1. Create Search Data Column
    #
    # Define a column to store full text search data
    #
    alter table(:users) do
      add :tsv_search, :tsvector
    end

    # 2. Create Search Data Index
    #
    # Create a GIN index on the full text search data column
    #
    create index(:users, [:tsv_search], name: :users_search_vector, using: "GIN")

    # 3. Define a Coalesce Function
    #
    # Coalesce the searchable fields into a single, space-separted, value. In
    # the example below the following user attributes are included in search:
    #
    # - email
    # - name
    # - first_name
    # - last_name
    #
    execute("""
      CREATE FUNCTION create_search_data_users() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.email, ' ') || ' ' ||
            coalesce(new.name, ' ') || ' ' ||
            coalesce(new.first_name, ' ') || ' ' ||
            coalesce(new.last_name, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

    # 4. Trigger the Function
    #
    # Call the function on `INSERT` and `UPDATE` actions
    #
    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON users FOR EACH ROW EXECUTE PROCEDURE create_search_data_users();
    """)
  end

  def down do
    # 1. Remove Triggers
    execute("drop function create_search_data_users();")

    # 2. Remove Functions
    execute("drop trigger tsvectorupdate on users;")

    # 3. Remove Indexes
    drop index(:users, [:tsv_search])

    # 4. Remove Columns
    alter table(:users) do
      remove :tsv_search
    end
  end
end
