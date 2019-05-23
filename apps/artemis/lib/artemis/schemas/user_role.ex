defmodule Artemis.UserRole do
  use Artemis.Schema

  schema "user_roles" do
    belongs_to :created_by, Artemis.User, foreign_key: :created_by_id
    belongs_to :role, Artemis.Role, on_replace: :delete
    belongs_to :user, Artemis.User, on_replace: :delete

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :created_by_id,
      :role_id,
      :user_id
    ]

  def required_fields, do: []

  def event_log_fields, do: []

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
    |> foreign_key_constraint(:created_by)
    |> foreign_key_constraint(:role_id)
    |> foreign_key_constraint(:user_id)
  end
end
