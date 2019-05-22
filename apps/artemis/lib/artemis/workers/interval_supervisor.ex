defmodule Artemis.IntervalSupervisor do
  @moduledoc """
  Starts and supervises interval workers.
  """

  use Supervisor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: (opts[:name] || __MODULE__))
  end

  def init(:ok) do
    children = [
      worker(Artemis.Worker.RepoResetOnInterval, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]

    supervise(children, opts)
  end
end
