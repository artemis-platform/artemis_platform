defmodule Artemis.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :client_key, :string
      add :client_secret, :string
      add :email, :string
      add :name, :string
      add :first_name, :string
      add :last_name, :string
      add :provider_uid, :string
      add :provider_data, :map
      timestamps()
    end

    create index(:users, [:client_key])
    create index(:users, [:client_secret])
    create unique_index(:users, [:client_key, :client_secret])
    create unique_index(:users, [:email])
  end
end
