defmodule ArtemisLog.Worker.EventLogListener do
  use GenServer

  import ArtemisPubSub

  alias ArtemisLog.CreateEventLog

  @topic "private:artemis:events"
  @events_blacklist [
    "event-log:created",
    "event-log:updated",
    "event-log:deleted"
  ]

  def start_link() do
    initial_state = %{}
    options = []

    GenServer.start_link(__MODULE__, initial_state, options)
  end

  # Callbacks

  def init(state) do
    if enabled?() do
      :ok = subscribe(@topic)
    end

    {:ok, state}
  end

  def handle_info(%{event: event, payload: payload}, state) do
    unless Enum.member?(@events_blacklist, event) do
      {:ok, _} = CreateEventLog.call(event, payload)
    end

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Helpers

  defp enabled?() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:subscribe_to_events)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end
end
