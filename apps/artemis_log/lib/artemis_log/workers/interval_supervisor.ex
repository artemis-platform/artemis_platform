defmodule ArtemisLog.IntervalSupervisor do
  use Supervisor

  @moduledoc """
  Starts and supervises interval workers.
  """

  def start_link(options \\ []) do
    Supervisor.start_link(__MODULE__, :ok, name: options[:name] || __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {ArtemisLog.Worker.DeleteEventLogsOnInterval, []},
      {ArtemisLog.Worker.DeleteHttpRequestLogsOnInterval, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    options = [strategy: :one_for_one]

    Supervisor.init(children, options)
  end
end
