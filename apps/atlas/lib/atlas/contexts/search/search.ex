defmodule Atlas.Search do
  use Atlas.Context

  import Atlas.UserAccess

  @default_page_size 5
  @searchable_resources %{
    "features" => [function: &Atlas.ListFeatures.call/1, permissions: "features:list"],
    "permissions" => [function: &Atlas.ListPermissions.call/1, permissions: "permissions:list"],
    "roles" => [function: &Atlas.ListRoles.call/1, permissions: "roles:list"],
    "users" => [function: &Atlas.ListUsers.call/1, permissions: "users:list"]
  }

  def call(params, user) do
    params = params
      |> Atlas.Helpers.keys_to_strings()
      |> Map.put("paginate", true)
      |> Map.put_new("page_size", @default_page_size)

    case Map.get(params, "query") do
      nil -> %{}
      "" -> %{}
      _ -> search(params, user)
    end
  end

  defp search(params, user) do
    resources = filter_resources_by_user_permissions(params, user)

    Enum.reduce(resources, %{}, fn ({key, options}, acc) ->
      function = Keyword.get(options, :function)
      value = function.(params)

      Map.put(acc, key, value)
    end)
  end

  defp filter_resources_by_user_permissions(params, user) do
    requested_keys = Map.get(params, "resources", Map.keys(@searchable_resources))
    requested_resources = Map.take(@searchable_resources, requested_keys)

    Enum.filter(requested_resources, fn ({_key, options}) ->
      permissions = Keyword.get(options, :permissions)

      has_all?(user, permissions)
    end)
  end
end
