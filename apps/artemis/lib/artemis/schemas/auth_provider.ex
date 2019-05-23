defmodule Artemis.AuthProvider do
  use Artemis.Schema

  schema "auth_providers" do
    field :data, :map
    field :type, :string
    field :uid, :string

    belongs_to :user, Artemis.User

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :data,
      :type,
      :uid,
      :user_id
    ]

  def required_fields,
    do: [
      :type,
      :uid,
      :user_id
    ]

  def event_log_fields,
    do: [
      :id,
      :type,
      :user_id
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
