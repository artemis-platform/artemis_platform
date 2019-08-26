defmodule ArtemisLog.Helpers do
  @doc """
  Detect if value is truthy
  """
  def present?(nil), do: false
  def present?(""), do: false
  def present?(0), do: false
  def present?(_value), do: true

  @doc """
  Converts an atom or string to an integer
  """
  def to_integer(value) when is_float(value), do: Kernel.trunc(value)
  def to_integer(value) when is_atom(value), do: to_integer(Atom.to_string(value))
  def to_integer(value) when is_bitstring(value), do: String.to_integer(value)
  def to_integer(value), do: value

  @doc """
  Converts an atom or integer to a bitstring
  """
  def to_string(value) when is_atom(value), do: Atom.to_string(value)
  def to_string(value) when is_integer(value), do: Integer.to_string(value)
  def to_string(value), do: value

  @doc """
  Recursively converts the keys of a map into a string.

  Example:

    keys_to_strings(%{nested: %{example: "value"}})

  Returns:

    %{"nested" => %{"example" => "value"}}

  """
  def keys_to_strings(map, options \\ [])
  def keys_to_strings(%_{} = struct, _options), do: struct

  def keys_to_strings(map, options) when is_map(map) do
    for {key, value} <- map, into: %{} do
      key =
        case is_atom(key) do
          false -> key
          true -> Atom.to_string(key)
        end

      {key, keys_to_strings(value, options)}
    end
  end

  def keys_to_strings(value, _), do: value

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

    nested =
      Enum.reduce(nested_keys, %{}, fn {key, keys}, acc ->
        value =
          map
          |> Map.get(key)
          |> deep_take(keys)

        Map.put(acc, key, value)
      end)

    Map.merge(simple, nested)
  end
end
