defmodule ArtemisLog.Helpers.Order do
  @doc """
  Default string separator for multiple order clauses
  """
  def default_order_separator, do: ","

  @doc """
  Process the `order` param and return a list of tuples
  """
  def get_order(params, options \\ [])

  def get_order(%{"order" => order}, options) when is_bitstring(order), do: get_order(order, options)

  def get_order(order, options) do
    order
    |> get_order_values(options)
    |> get_order_directions()
  end

  # Helpers

  defp get_order_values(value, options) when is_bitstring(value) do
    by = Keyword.get(options, :separator, default_order_separator())

    value
    |> String.split(by)
    |> Enum.reject(&(&1 == ""))
  end

  defp get_order_values(value, _) when is_list(value), do: value
  defp get_order_values(value, _), do: [value]

  defp get_order_directions(values) do
    Enum.map(values, &get_order_direction(&1))
  end

  defp get_order_direction(value) do
    # Descending keys start with a `-`, e.g. `-name`.
    case String.first(value) do
      "-" ->
        key =
          value
          |> String.slice(1..-1)
          |> String.to_atom()

        {:desc, key}

      _ ->
        {:asc, String.to_atom(value)}
    end
  end
end
