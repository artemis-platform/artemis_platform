defmodule Artemis.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :description, :text
      add :name, :string
      add :slug, :string
      timestamps()
    end

    create unique_index(:roles, [:slug])
    create unique_index(:roles, [:name])
  end
end
