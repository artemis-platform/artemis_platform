defmodule ArtemisLog.Repo.Order do
  import Ecto.Query

  @doc """
  Default string separator for multiple order clauses
  """
  def default_order_separator, do: ","

  @doc """
  Process the `order` param and add an ecto order_by clause for each value.
  """
  def order_query(query, params, options \\ [])
  def order_query(query, _params, active: false), do: query
  def order_query(query, %{"order" => order}, _options) when is_bitstring(order) do
    items = order
      |> get_order_values(default_order_separator())
      |> get_order_directions()

    order_by(query, ^items)
  end
  def order_query(query, _params, _options), do: query

  # Helpers

  defp get_order_values(value, by) when is_bitstring(value) do
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
        key = value
          |> String.slice(1..-1)
          |> String.to_atom()

        {:desc, key}
      _ ->
        {:asc, String.to_atom(value)}
    end
  end
end
