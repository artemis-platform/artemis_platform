defmodule ArtemisLog.EventLog do
  use ArtemisLog.Schema

  schema "event_logs" do
    field :action, :string
    field :meta, :map
    field :session_id, :string
    field :user_id, :integer
    field :user_name, :string

    timestamps()
  end

  # Callbacks

  def updatable_fields,
    do: [
      :action,
      :meta,
      :session_id,
      :user_id,
      :user_name
    ]

  def required_fields,
    do: [
      :action,
      :user_id,
      :user_name
    ]

  # Changesets

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, updatable_fields())
    |> validate_required(required_fields())
  end
end
