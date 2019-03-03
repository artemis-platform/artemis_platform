defmodule Artemis.Repo.Migrations.CreatePermissionsRoles do
  use Ecto.Migration

  def change do
    create table(:permissions_roles) do
      add :permission_id, references(:permissions, on_delete: :delete_all), null: false
      add :role_id, references(:roles, on_delete: :delete_all), null: false
    end

    create unique_index(:permissions_roles, [:permission_id, :role_id])
  end
end
