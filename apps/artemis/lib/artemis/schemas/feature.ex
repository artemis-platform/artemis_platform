defmodule Artemis.Feature do
  use Artemis.Schema

  schema "features" do
    field :active, :boolean, default: false
    field :description, :string
    field :name, :string
    field :slug, :string

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :active,
      :description,
      :name,
      :slug
    ]

  def required_fields,
    do: [
      :slug
    ]

  def event_log_fields,
    do: [
      :id,
      :active,
      :slug
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> unique_constraint(:slug)
  end

  # Queries

  def active?(%Feature{} = feature), do: feature.active

  def active?(slug) do
    case Repo.get_by(Feature, slug: slug) do
      nil -> false
      record -> record.active
    end
  end
end
