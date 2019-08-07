defmodule ArtemisLog.Worker.DeleteEventLogsOnInterval do
  use ArtemisLog.IntervalWorker,
    delayed_start: true,
    enabled: enabled?(),
    interval: :timer.hours(4),
    log_limit: 128,
    name: :event_log_history_on_interval

  alias Artemis.GetSystemUser
  alias ArtemisLog.DeleteAllEventLogsOlderThan

  # Callbacks

  @impl true
  def call(_data, _config) do
    user = GetSystemUser.call()
    interval = get_max_days() * 24 * 60 * 60

    timestamp =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(interval)
      |> DateTime.from_unix!(:second)

    DeleteAllEventLogsOlderThan.call(timestamp, user)
  end

  # Helpers

  defp enabled?() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:delete_event_logs_on_interval)
    |> Keyword.fetch!(:enabled)
    |> String.downcase()
    |> String.equivalent?("true")
  end

  defp get_max_days() do
    :artemis_log
    |> Application.fetch_env!(:actions)
    |> Keyword.fetch!(:delete_event_logs_on_interval)
    |> Keyword.fetch!(:max_days)
    |> String.to_integer()
  end
end
