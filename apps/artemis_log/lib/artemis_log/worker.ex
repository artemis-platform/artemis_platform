defmodule ArtemisLog.Worker do
  use GenServer

  import ArtemisPubSub
  
  alias ArtemisLog.CreateEventLog

  @subscribe_to_events Application.get_env(:artemis_log, :subscribe_to_events, true)
  @topic "private:artemis"

  def start_link() do
    initial_state = %{}
    options = []

    GenServer.start_link(__MODULE__, initial_state, options)
  end

  # Callbacks

  def init(state) do
    if @subscribe_to_events do
      :ok = subscribe(@topic)
    end

    {:ok, state}
  end

  def handle_info(%{event: event, payload: payload}, state) do
    {:ok, _} = CreateEventLog.call(event, payload)

    {:noreply, state}
  end
  def handle_info(_, state) do
    {:noreply, state}
  end
end
