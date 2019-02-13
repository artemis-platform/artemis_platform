defmodule AtlasAmqp.Application do
  @moduledoc false

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(AtlasAmqp.Connection, []),
      worker(AtlasAmqp.Consumer, [])
    ]

    opts = [strategy: :one_for_one, name: AtlasAmqp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
