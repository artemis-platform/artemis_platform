defmodule ArtemisPubSub.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Phoenix.PubSub, name: ArtemisPubSub},
      # supervisor(Phoenix.PubSub.PG2, [ArtemisPubSub, []]),
      supervisor(ArtemisPubSub.Presence, [])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
