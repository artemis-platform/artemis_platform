defmodule Artemis.Ecto.Helpers do
  @doc """
  # Print Errors

  Converts ecto errors into human readable strings.

  > Based on https://gist.github.com/sergio1990/537fcf958752ae223baa4a782ee09109

  By default `changeset.errors` returns errors as keyword list, where key is name of the field
  and value is part of message. For example, `[body: "is required"]`.

  This method transforms errors in list which is ready to pass it, for example, in response of
  a JSON API request.

  ## Usage Example

  ```elixir
  print_errors([body: "is required"])
  # => ["Body is required"]
  ```

  ## Usage Example with Interpolations

  ```elixir
  print_errors([login: {"should be at most %{count} character(s)", [count: 10]}])
  # => ["Login should be at most 10 character(s)"]
  ```

  """
  def print_errors(%Ecto.Changeset{errors: errors}), do: print_errors(errors)
  def print_errors(errors) when is_list(errors), do: Enum.map(errors, &print_error/1)
  def print_errors(error), do: print_error(error)

  defp print_error({field_name, message}) when is_bitstring(message) do
    human_field_name = field_name
      |> Atom.to_string
      |> String.replace("_", " ")
      |> String.capitalize

    human_field_name <> " " <> message
  end
  defp print_error({field_name, {message, variables}}) do
    compound_message = interpolate(message, variables)

    print_error({field_name, compound_message})
  end

  defp interpolate(string, [{name, value} | rest]) do
    string
    |> String.replace("%{#{name}}", as_string(value))
    |> interpolate(rest)
  end
  defp interpolate(string, []), do: string

  defp as_string(value) when is_integer(value), do: Integer.to_string(value)
  defp as_string(value) when is_bitstring(value), do: value
  defp as_string(value) when is_atom(value), do: Atom.to_string(value)
end
