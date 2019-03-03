defmodule Artemis.Repo.Migrations.CreateSearchTriggers do
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
    alter table(:features) do
      add :tsv_search, :tsvector
    end

    alter table(:permissions) do
      add :tsv_search, :tsvector
    end

    alter table(:roles) do
      add :tsv_search, :tsvector
    end

    alter table(:users) do
      add :tsv_search, :tsvector
    end

    # 2. Create Search Data Index
    #
    # Create a GIN index on the full text search data column
    #
    create index(:features, [:tsv_search], name: :features_search_vector, using: "GIN")
    create index(:permissions, [:tsv_search], name: :permissions_search_vector, using: "GIN")
    create index(:roles, [:tsv_search], name: :roles_search_vector, using: "GIN")
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
      CREATE FUNCTION create_search_data_features() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.name, ' ') || ' ' ||
            coalesce(new.slug, ' ') || ' ' ||
            coalesce(new.description, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE FUNCTION create_search_data_permissions() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.name, ' ') || ' ' ||
            coalesce(new.slug, ' ') || ' ' ||
            coalesce(new.description, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE FUNCTION create_search_data_roles() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.name, ' ') || ' ' ||
            coalesce(new.slug, ' ') || ' ' ||
            coalesce(new.description, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

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
      ON features FOR EACH ROW EXECUTE PROCEDURE create_search_data_features();
    """)

    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON permissions FOR EACH ROW EXECUTE PROCEDURE create_search_data_permissions();
    """)

    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON roles FOR EACH ROW EXECUTE PROCEDURE create_search_data_roles();
    """)

    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON users FOR EACH ROW EXECUTE PROCEDURE create_search_data_users();
    """)
  end

  def down do
    # 1. Remove Triggers
    execute("drop function create_search_data_features();")
    execute("drop function create_search_data_permissions();")
    execute("drop function create_search_data_roles();")
    execute("drop function create_search_data_users();")

    # 2. Remove Functions
    execute("drop trigger tsvectorupdate on features;")
    execute("drop trigger tsvectorupdate on permissions;")
    execute("drop trigger tsvectorupdate on roles;")
    execute("drop trigger tsvectorupdate on users;")

    # 3. Remove Indexes
    drop index(:features, [:tsv_search])
    drop index(:permissions, [:tsv_search])
    drop index(:roles, [:tsv_search])
    drop index(:users, [:tsv_search])

    # 4. Remove Columns
    alter table(:features) do
      remove :tsv_search
    end

    alter table(:permissions) do
      remove :tsv_search
    end

    alter table(:roles) do
      remove :tsv_search
    end

    alter table(:users) do
      remove :tsv_search
    end
  end
end
