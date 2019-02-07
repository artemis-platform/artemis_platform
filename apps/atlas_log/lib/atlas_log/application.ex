defmodule AtlasLog.Application do
  @moduledoc """
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(AtlasLog.Repo, []),
      worker(AtlasLog.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: AtlasLog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
