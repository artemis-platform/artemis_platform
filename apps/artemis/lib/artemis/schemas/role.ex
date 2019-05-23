defmodule Artemis.Role do
  use Artemis.Schema
  use Assoc.Schema, repo: Artemis.Repo

  schema "roles" do
    field :description, :string
    field :name, :string
    field :slug, :string

    has_many :user_roles, Artemis.UserRole, on_delete: :delete_all, on_replace: :delete
    has_many :users, through: [:user_roles, :user]

    many_to_many :permissions, Artemis.Permission, join_through: "permissions_roles", on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :description,
      :name,
      :slug
    ]

  def required_fields,
    do: [
      :name,
      :slug
    ]

  def updatable_associations,
    do: [
      permissions: Artemis.Permission
    ]

  def event_log_fields,
    do: [
      :id,
      :slug
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
