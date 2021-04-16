defmodule Artemis.Helpers do
  require Logger

  @doc """
  Generate a random string
  """
  def random_string(string_length) do
    string_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
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
    Enum.reduce(grouped_data, %{}, fn {key, values}, acc ->
      Map.put(acc, key, function.(values))
    end)
  end

  @doc """
  Takes a collection of values and an attribute and returns the max value for that attribute.
  """
  def max_by_attribute(values, attribute, fun \\ fn x -> x end)
  def max_by_attribute([], _, _), do: nil

  def max_by_attribute(values, attribute, fun) do
    values
    |> Enum.max_by(&fun.(Map.get(&1, attribute)))
    |> Map.get(attribute)
  end

  @doc """
  Takes a collection of values and an attribute and returns the min value for that attribute.
  """
  def min_by_attribute(values, attribute, fun \\ fn x -> x end)
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
  Converts a nested list to a nested map. Example:

  Input: [[:one, :two, 3], [:one, :three, 3]]
  Output: %{one: %{two: 2, three: 3}}
  """
  def nested_list_to_map(nested_list) do
    Enum.reduce(nested_list, %{}, fn item, acc ->
      deep_merge(acc, list_to_map(item))
    end)
  end

  @doc """
  Converts a simple list to a nested map. Example:

  Input: [:one, :two, 3]
  Output: %{one: %{two: 2}}
  """
  def list_to_map([head | tail]) when tail == [], do: head
  def list_to_map([head | tail]) when is_integer(head), do: list_to_map([Integer.to_string(head) | tail])
  def list_to_map([head | tail]), do: Map.put(%{}, head, list_to_map(tail))

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
    values =
      tasks
      |> Map.values()
      |> async_await_many

    tasks
    |> Map.keys()
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
      key =
        case is_bitstring(key) do
          false ->
            key

          true ->
            case Keyword.get(options, :whitelist) do
              nil ->
                String.to_atom(key)

              whitelist ->
                case Enum.member?(whitelist, key) do
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
  Serialize process id (pid) number to string
  """
  def serialize_pid(pid) when is_pid(pid) do
    pid
    |> :erlang.pid_to_list()
    |> :erlang.list_to_binary()
  end

  @doc """
  Deserialize process id (pid) string to pid
  """
  def deserialize_pid("#PID" <> string), do: deserialize_pid(string)

  def deserialize_pid(string) do
    string
    |> :erlang.binary_to_list()
    |> :erlang.list_to_pid()
  end

  @doc """
  Recursive version of `Map.delete/2`. Adds support for nested values:

  Example:

    map = %{
      hello: "world",
      nested: %{example: "value", hello: "world"}
    }

    deep_delete(map, [:nested, :example])

  Returns:

    %{
      nested: %{example: "value"}
    }

  """
  def deep_delete(data, delete_key) when is_map(data) do
    data
    |> Map.delete(delete_key)
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      Map.put(acc, key, deep_delete(value, delete_key))
    end)
  end

  def deep_delete(data, _), do: data

  @doc """
  Recursive version of `Map.get/2`. Adds support for nested values:

  Example:

    map = %{
      simple: "simple",
      nested: %{example: "value", other: "value"}
    }

    deep_get(map, [:nested, :example])

  Returns:

    "value"

  """
  def deep_get(data, keys, default \\ nil)

  def deep_get(data, [current_key | remaining_keys], default) when is_map(data) do
    value = Map.get(data, current_key)

    case remaining_keys do
      [] -> value
      _ -> deep_get(value, remaining_keys, default)
    end
  end

  def deep_get(_data, _, default), do: default

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

  @doc """
  Print entire value without truncation
  """
  def print(value) do
    IO.inspect(value, limit: :infinity, printable_limit: :infinity)
  end

  @doc """
  Benchmark execution time

  Options:

      log_level -> when not set, uses default value set in an env variable

  Example:

      Artemis.Helpers.benchmark("Sleep Performance", fn ->
        :timer.sleep(5_000)
      end, log_level: :info)
  """
  def benchmark(callback), do: benchmark(nil, callback)

  def benchmark(callback, options) when is_list(options), do: benchmark(nil, callback, options)

  def benchmark(key, callback, options \\ []) do
    start_time = Timex.now()
    result = callback.()
    end_time = Timex.now()
    duration = Timex.diff(end_time, start_time, :milliseconds)

    default_log_level = Artemis.Helpers.AppConfig.fetch!(:artemis, :benchmark, :default_log_level)
    options = Keyword.put_new(options, :log_level, default_log_level)

    message = [
      type: "Benchmark",
      key: key,
      duration: "#{duration}ms"
    ]

    log(message, options)

    result
  end

  @doc """
  Send values to Logger
  """
  def log(values, options \\ [])

  def log(values, options) when is_list(values) do
    message = format_log_message(values)

    log(message, options)
  end

  def log(message, options) do
    log_level = get_log_level(options)

    Logger.log(log_level, message)
  end

  defp format_log_message(values) do
    values
    |> Enum.map(fn {key, value} ->
      case is_nil(value) do
        true -> nil
        false -> "[#{key}: #{value}]"
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp get_log_level(options) do
    default_log_level = :info

    log_level =
      options
      |> Keyword.get(:log_level, Keyword.get(options, :level))
      |> Kernel.||(default_log_level)
      |> Artemis.Helpers.to_string()

    case log_level do
      "emergency" -> :emergency
      "alert" -> :alert
      "critical" -> :critical
      "error" -> :error
      "warning" -> :warning
      "notice" -> :notice
      "info" -> :info
      _ -> :debug
    end
  end

  @doc """
  Log application start
  """
  def log_application_start(name) do
    type = "ApplicationStart"

    log(type: type, key: name, start: Timex.now())
  end

  @doc """
  Log rescued errors
  """
  def rescue_log(stacktrace \\ nil, caller, error) do
    default_values = [
      caller: serialize_caller(caller),
      error: Map.get(error, :__struct__),
      message: Map.get(error, :message, inspect(error)),
      stacktrace: serialize_stacktrace(stacktrace)
    ]

    log_message = format_log_message(default_values)

    Logger.error(log_message)
  end

  defp serialize_caller(caller) when is_map(caller), do: Map.get(caller, :__struct__)
  defp serialize_caller(caller), do: caller

  defp serialize_stacktrace(nil), do: nil

  defp serialize_stacktrace(stacktrace) do
    stracktrace =
      stacktrace
      |> Enum.map(&inspect(&1))
      |> Enum.join("\n    ")

    "\n    " <> stracktrace
  end

  @doc """
  Send values to Error
  """
  def error(values) when is_list(values) do
    message = format_log_message(values)

    Logger.error(message)
  end

  def error(message), do: Logger.error(message: message)

  @doc """
  Convert an Ecto Query into SQL

  Example:

      Customer
      |> distinct_query(params, default: false)
      |> order_query(params)
      |> Artemis.Helpers.print_to_sql(Artemis.Repo)
      |> Repo.all()

  """
  def print_to_sql(query, repo) do
    IO.inspect(Ecto.Adapters.SQL.to_sql(:all, repo, query))

    query
  end
end
