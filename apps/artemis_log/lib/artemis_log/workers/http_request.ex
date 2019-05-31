defmodule ArtemisLog.Worker.HttpRequest do
  use GenServer

  import ArtemisPubSub

  alias ArtemisLog.CreateHttpRequestLog

  @topic "private:artemis:http-requests"

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

  def handle_info(%{event: _event, payload: payload}, state) do
    {:ok, _} = CreateHttpRequestLog.call(payload)

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  # Helpers

  defp enabled?(), do: Application.fetch_env!(:artemis_log, :subscribe_to_http_requests)
end
