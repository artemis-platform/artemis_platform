defmodule Atlas.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :name, :string
      add :first_name, :string
      add :last_name, :string
      add :provider_uid, :string
      add :provider_data, :map
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
