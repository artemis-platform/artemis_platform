defmodule ArtemisLog.ListEventLogs do
  use ArtemisLog.Context

  import ArtemisLog.Helpers.Search

  alias ArtemisLog.EventLog
  alias ArtemisLog.Repo

  @default_page_size 25

  def call(params \\ %{}, _user) do
    params = default_params(params)

    EventLog
    |> search_filter(params)
    |> Repo.paginate(params)
  end

  defp default_params(params) do
    params
    |> ArtemisLog.Helpers.keys_to_strings()
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("page", Map.get(params, "page_number", 1))
  end
end
