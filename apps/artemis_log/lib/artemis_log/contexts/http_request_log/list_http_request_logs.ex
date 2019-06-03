defmodule ArtemisLog.ListHttpRequestLogs do
  use ArtemisLog.Context

  import Ecto.Query

  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  @default_order "-inserted_at"
  @default_page_size 25
  @default_paginate true

  def call(params \\ %{}, user) do
    params = default_params(params)

    HttpRequestLog
    |> order_query(params)
    |> restrict_access(user)
    |> get_records(params)
  end

  defp default_params(params) do
    params
    |> ArtemisLog.Helpers.keys_to_strings()
    |> Map.put_new("order", @default_order)
    |> Map.put_new("page", Map.get(params, "page_number", 1))
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("paginate", @default_paginate)
  end

  defp restrict_access(query, user) do
    cond do
      has?(user, "http-request-logs:access:all") -> query
      has?(user, "http-request-logs:access:self") -> where(query, [el], el.user_id == ^user.id)
      true -> where(query, [el], is_nil(el.id))
    end
  end

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, params)
  defp get_records(query, _params), do: Repo.all(query)
end
