defmodule ArtemisLog.ListHttpRequestLogs do
  use ArtemisLog.Context

  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  @default_order "-inserted_at"
  @default_page_size 25

  def call(params \\ %{}, _user) do
    params = default_params(params)

    HttpRequestLog
    |> order_query(params)
    |> Repo.paginate(params)
  end

  defp default_params(params) do
    params
    |> ArtemisLog.Helpers.keys_to_strings()
    |> Map.put_new("order", @default_order)
    |> Map.put_new("page", Map.get(params, "page_number", 1))
    |> Map.put_new("page_size", @default_page_size)
  end
end
