defmodule Artemis.GetSystemUser do
  use Artemis.ContextCache,
    cache_reset_on_events: [
      "permission:created",
      "permission:deleted",
      "permission:updated",
      "role:created",
      "role:deleted",
      "role:updated",
      "user:created",
      "user:deleted",
      "user:updated"
    ],
    cachex_options: [
      expiration: :timer.minutes(60),
      limit: 5
    ]

  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.User

  @default_preload [:permissions]

  def call!(options \\ []) do
    get_record(options, &Repo.get_by!/2)
  end

  def call(options \\ []) do
    get_record(options, &Repo.get_by/2)
  end

  defp get_record(options, get_by) do
    system_user = Application.fetch_env!(:artemis, :users)[:system_user]

    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(email: system_user.email)
  end

  # Callbacks

  @impl true
  def get_cache_key(args), do: [:system_user, options: args]
end
