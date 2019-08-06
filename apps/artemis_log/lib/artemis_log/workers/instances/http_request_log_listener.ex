defmodule ArtemisLog.Worker.HttpRequestLogListener do
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

  defp enabled?() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:subscribe_to_http_requests)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end
end
