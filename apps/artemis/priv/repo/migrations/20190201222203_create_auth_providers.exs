defmodule Artemis.Repo.Migrations.CreateAuthProviders do
  use Ecto.Migration

  def change do
    create table(:auth_providers) do
      add :data, :map
      add :type, :string
      add :uid, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create index(:auth_providers, [:type])
    create unique_index(:auth_providers, [:type, :uid])

    execute "CREATE INDEX index_auth_providers_data ON auth_providers USING gin(data jsonb_path_ops);"
  end
end
