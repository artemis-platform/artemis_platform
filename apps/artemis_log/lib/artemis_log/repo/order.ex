defmodule ArtemisLog.Repo.Order do
  import Ecto.Query

  @doc """
  Process the `order` param and add an ecto order_by clause for each value.
  """
  def order_query(query, params, options \\ [])
  def order_query(query, _params, active: false), do: query

  def order_query(query, %{"order" => order}, _options) when is_bitstring(order) do
    items = ArtemisLog.Helpers.Order.get_order(order)

    order_by(query, ^items)
  end

  def order_query(query, _params, _options), do: query
end
