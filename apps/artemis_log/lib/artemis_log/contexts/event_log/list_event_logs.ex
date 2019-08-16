defmodule ArtemisLog.ListEventLogs do
  use ArtemisLog.Context

  import ArtemisLog.Helpers.Filter
  import ArtemisLog.Helpers.Search
  import Ecto.Query

  alias ArtemisLog.EventLog
  alias ArtemisLog.Repo

  @default_order "-inserted_at"
  @default_page_size 25
  @default_paginate true

  def call(params \\ %{}, user) do
    params = default_params(params)

    EventLog
    |> filter_query(params, user)
    |> search_filter(params)
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
      has?(user, "event-logs:access:all") -> query
      has?(user, "event-logs:access:self") -> where(query, [el], el.user_id == ^user.id)
      true -> where(query, [el], is_nil(el.id))
    end
  end

  defp filter_query(query, %{"filters" => filters}, _user) when is_map(filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      filter(acc, key, value)
    end)
  end

  defp filter_query(query, _params, _user), do: query

  defp filter(query, _key, nil), do: query
  defp filter(query, _key, ""), do: query
  defp filter(query, "action", value), do: where(query, [el], el.action in ^split(value))
  defp filter(query, "resource_id", value), do: where(query, [el], el.resource_id in ^split(value))
  defp filter(query, "resource_type", value), do: where(query, [el], el.resource_type in ^split(value))
  defp filter(query, "session_id", value), do: where(query, [el], el.session_id in ^split(value))
  defp filter(query, "user_id", value), do: where(query, [el], el.user_id in ^split(value))
  defp filter(query, "user_name", value), do: where(query, [el], el.user_name in ^split(value))
  defp filter(query, _key, _value), do: query

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, params)
  defp get_records(query, _params), do: Repo.all(query)
end
