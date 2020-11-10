defmodule Artemis.Helpers.Time do
  @doc """
  Return milliseconds from given time. If a time is not passed, current
  timestamp is used.
  """
  def get_milliseconds_to_next_minute(time \\ nil) do
    start = time || Timex.now()

    next_minute =
      start
      |> Timex.shift(minutes: 1)
      |> Map.put(:second, 0)
      |> DateTime.truncate(:second)

    next_minute
    |> Timex.diff(start, :microseconds)
    |> Kernel./(1000)
    |> ceil()
  end
end
