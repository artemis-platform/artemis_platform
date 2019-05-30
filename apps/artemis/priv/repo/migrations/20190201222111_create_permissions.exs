defmodule Artemis.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :description, :text
      add :name, :string
      add :slug, :string
      timestamps(type: :utc_datetime)
    end

    create unique_index(:permissions, [:slug])
  end
end
