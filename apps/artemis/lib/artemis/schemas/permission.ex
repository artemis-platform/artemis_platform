defmodule Artemis.Permission do
  use Artemis.Schema

  schema "permissions" do
    field :description, :string
    field :name, :string
    field :slug, :string

    many_to_many :roles, Artemis.Role, join_through: "permissions_roles", on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields, do: [:description, :name, :slug]

  def required_fields, do: [:name, :slug]

  def event_log_fields, do: [:id, :slug]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> unique_constraint(:slug)
  end
end
