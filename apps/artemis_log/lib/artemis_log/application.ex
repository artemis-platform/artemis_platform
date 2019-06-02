defmodule ArtemisLog.Application do
  @moduledoc """
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ArtemisLog.Repo, []),
      worker(ArtemisLog.Worker.Event, []),
      worker(ArtemisLog.Worker.HttpRequest, [])
    ]

    opts = [strategy: :one_for_one, name: ArtemisLog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
