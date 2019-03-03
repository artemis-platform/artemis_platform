defmodule ArtemisLog.Filter do
  @moduledoc """
  Filter the fields for any struct that implements the filter behaviour. All
  other values pass-through and are logged without filtering.
  """

  import ArtemisLog.Helpers, only: [deep_take: 2]

  def call(%{__struct__: struct} = data) do
    case defined_log_fields?(struct) do
      true -> deep_take(data, struct.event_log_fields())
      false -> data
    end
  end
  def call(data), do: data

  defp defined_log_fields?(struct) do
    struct.__info__(:functions)
    |> Keyword.keys
    |> Enum.member?(:event_log_fields)
  end
end
