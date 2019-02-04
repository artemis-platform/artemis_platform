defmodule Atlas.Context do
  defmodule Error do
    defexception message: "Context Error"
  end

  @broadcast_topic "private:atlas"

  def broadcast_topic, do: @broadcast_topic

  def broadcast_result({:ok, payload} = result, event) do
    :ok = AtlasPubSub.broadcast(@broadcast_topic, event, payload)

    result
  end
  def broadcast_result({:error, _} = result, _event), do: result
  def broadcast_result(payload, event), do: broadcast_result({:ok, payload}, event)

  defmacro __using__(_opts) do
    quote do
      import Atlas.Context
    end
  end
end
