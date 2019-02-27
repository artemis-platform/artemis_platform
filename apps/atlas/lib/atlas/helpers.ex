defmodule Atlas.Helpers do
  @doc """
  Generate a random string
  """
  def random_string(string_length) do
    string_length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, string_length)
  end

  @doc """
  Detect if value is truthy
  """
  def present?(nil), do: false
  def present?(""), do: false
  def present?(0), do: false
  def present?(_value), do: true

  @doc """
  Detect if a key's value is truthy
  """
  def present?(entry, key) when is_list(entry) do
    entry
    |> Keyword.get(key)
    |> present?
  end
  def present?(entry, key) when is_map(entry) do
    entry
    |> Map.get(key)
    |> present?
  end

  @doc """
  Renames a key in a map. If the key does not exist, original map is returned.
  """
  def rename_key(map, current_key, new_key) when is_map(map) do
    case Map.has_key?(map, current_key) do
      true -> Map.put(map, new_key, Map.get(map, current_key))
      false -> map
    end
  end

  @doc """
  Takes the result of a `group_by` statement, applying the passed function
  to each grouping's values. Returns a map.
  """
  def reduce_group_by(grouped_data, function) do
    Enum.reduce(grouped_data, %{}, fn ({key, values}, acc) ->
      Map.put(acc, key, function.(values))
    end)
  end

  @doc """
  Takes a collection of values and an attribute and returns the max value for that attribute.
  """
  def max_by_attribute(values, attribute, fun \\ fn (x) -> x end)
  def max_by_attribute([], _, _), do: nil
  def max_by_attribute(values, attribute, fun) do
    values
    |> Enum.max_by(&fun.(Map.get(&1, attribute)))
    |> Map.get(attribute)
  end

  @doc """
  Takes a collection of values and an attribute and returns the min value for that attribute.
  """
  def min_by_attribute(values, attribute, fun \\ fn (x) -> x end)
  def min_by_attribute([], _, _), do: []
  def min_by_attribute(values, attribute, fun) do
    values
    |> Enum.min_by(&fun.(Map.get(&1, attribute)))
    |> Map.get(attribute)
  end

  @doc """
  Returns a titlecased string. Example:

      Input: hello world
      Ouput: Hello World
  """
  def titlecase(value) do
    value
    |> String.split(" ")
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join(" ")
  end

  @doc """
  Returns a simplified module name. Example:

      Input: Elixir.MyApp.MyModule
      Ouput: MyModule
  """
  def module_name(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> String.to_atom()
  end

  @doc """
  Converts a nested list to a nested map. Example:

  Input: [[:one, :two, 3], [:one, :three, 3]]
  Output: %{one: %{two: 2, three: 3}}
  """
  def nested_list_to_map(nested_list) do
    Enum.reduce(nested_list, %{}, fn (item, acc) ->
      deep_merge(acc, list_to_map(item))
    end)
  end

  @doc """
  Converts a simple list to a nested map. Example:

  Input: [:one, :two, 3]
  Output: %{one: %{two: 2}}
  """
  def list_to_map([head|tail]) when tail == [], do: head
  def list_to_map([head|tail]) when is_integer(head), do: list_to_map([Integer.to_string(head)|tail])
  def list_to_map([head|tail]), do: Map.put(%{}, head, list_to_map(tail))

  @doc """
  Deep merges two maps

  See: https://stackoverflow.com/questions/38864001/elixir-how-to-deep-merge-maps/38865647#38865647
  """
  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  defp deep_resolve(_key, left = %{}, right = %{}) do
    # Key exists in both maps, and both values are maps as well.
    # These can be merged recursively.
    deep_merge(left, right)
  end
  defp deep_resolve(_key, _left, right) do
    # Key exists in both maps, but at least one of the values is
    # NOT a map. We fall back to standard merge behavior, preferring
    # the value on the right.
    right
  end

  # Tasks

  @doc """
  Runs a list of tasks in parallel. Example:

    async_await_many([&task_one/0, &task_two/0])

  Returns:

    ["task_one/0 result", "task_two/0 result"]

  ## Maps

  Also accepts a map:

    async_await_many(%{
      one: &task_one/0,
      two: &task_two/0
    })

  Returns:

    %{
      one: "task_one/0 result",
      two: "task_two/0 result"
    }

  """
  def async_await_many(tasks) when is_list(tasks) do
    tasks
    |> Enum.map(&Task.async(&1))
    |> Enum.map(&Task.await/1)
  end
  def async_await_many(tasks) when is_map(tasks) do
    values = tasks
      |> Map.values
      |> async_await_many

    tasks
    |> Map.keys
    |> Enum.zip(values)
    |> Enum.into(%{})
  end

  @doc """
  Recursively converts the keys of a map into an atom.

  Options:

    `:whitelist` -> List of strings to convert to atoms. When passed, only strings in whitelist will be converted.

  Example:

    keys_to_atoms(%{"nested" => %{"example" => "value"}})

  Returns:

    %{nested: %{example: "value"}}
  """
  def keys_to_atoms(map, options \\ [])
  def keys_to_atoms(%_{} = struct, _options), do: struct
  def keys_to_atoms(map, options) when is_map(map) do
    for {key, value} <- map, into: %{} do
      key = case is_bitstring(key) do
        false -> key
        true -> case Keyword.get(options, :whitelist) do
          nil -> String.to_atom(key)
          whitelist -> case Enum.member?(whitelist, key) do
            false -> key
            true -> String.to_atom(key)
          end
        end
      end

      {key, keys_to_atoms(value, options)}
    end
  end
  def keys_to_atoms(value, _), do: value

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
      key = case is_atom(key) do
        false -> key
        true -> Atom.to_string(key)
      end

      {key, keys_to_strings(value, options)}
    end
  end
  def keys_to_strings(value, _), do: value

  @doc """
  Serialize process id (pid) number to string
  """
  def serialize_pid(pid) when is_pid(pid) do
    pid
    |> :erlang.pid_to_list
    |> :erlang.list_to_binary
  end

  @doc """
  Deserialize process id (pid) string to pid
  """
  def deserialize_pid("#PID" <> string), do: deserialize_pid(string)
  def deserialize_pid(string) do
    string
    |> :erlang.binary_to_list
    |> :erlang.list_to_pid
  end

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
