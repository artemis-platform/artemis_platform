defmodule Artemis.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :client_key, :string
      add :client_secret, :string
      add :description, :text
      add :email, :string
      add :first_name, :string
      add :image, :string
      add :last_log_in_at, :utc_datetime
      add :last_name, :string
      add :name, :string
      add :session_id, :string
      timestamps(type: :utc_datetime)
    end

    create index(:users, [:client_key])
    create index(:users, [:client_secret])
    create unique_index(:users, [:client_key, :client_secret])
    create unique_index(:users, [:email])
  end
end
