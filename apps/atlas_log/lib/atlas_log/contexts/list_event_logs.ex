defmodule AtlasLog.ListEventLogs do
  alias AtlasLog.EventLog
  alias AtlasLog.Repo

  @default_page_size 25

  def call(params \\ %{}) do
    params = default_params(params)

    Repo.paginate(EventLog, params)
  end

  defp default_params(params) do
    params
    |> AtlasLog.Helpers.keys_to_strings()
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("page", Map.get(params, "page_number", 1))
  end
end
