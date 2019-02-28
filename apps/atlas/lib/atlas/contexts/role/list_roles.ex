defmodule Atlas.ListRoles do
  use Atlas.Context

  import Atlas.Helpers.Search
  import Ecto.Query

  alias Atlas.Repo
  alias Atlas.Role

  @default_page_size 25
  @default_preload []

  def call(params \\ %{}) do
    params = default_params(params)

    Role
    |> preload(^Map.get(params, "preload"))
    |> search_filter(params)
    |> get_records(params)
  end

  defp default_params(params) do
    params
    |> Atlas.Helpers.keys_to_strings()
    |> Map.put_new("page_size", @default_page_size)
    |> Map.put_new("preload", @default_preload)
  end

  defp get_records(query, %{"paginate" => true} = params), do: Repo.paginate(query, pagination_params(params))
  defp get_records(query, _params), do: Repo.all(query)
end
