defmodule AtlasLog.Helpers do
  @doc """
  Recursive version of `Map.take/2`. Adds support for nested values:

  Example:

    map = %{
      simple: "simple",
      nested: %{example: "value", other: "value"}
    }

    deep_take(map, [:simple, nested: [:example]])

  Returns:

    map = %{
      simple: "simple",
      nested: %{example: "value"}
    }

  """
  def deep_take(map, keys) when is_map(map) do
    {nested_keys, simple_keys} = Enum.split_with(keys, &is_tuple/1)

    simple = Map.take(map, simple_keys)
    nested = Enum.reduce(nested_keys, %{}, fn ({key, keys}, acc) ->
      value = map
        |> Map.get(key)
        |> deep_take(keys)

      Map.put(acc, key, value)
    end)

    Map.merge(simple, nested)
  end
end
