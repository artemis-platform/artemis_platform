defmodule ArtemisLog.DeleteAllHttpRequestLogsOlderThan do
  use ArtemisLog.Context

  import Ecto.Query

  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  def call!(timestamp, user) do
    case call(timestamp, user) do
      {:error, _} -> raise(ArtemisLog.Context.Error, "Error deleting http request logs")
      {:ok, result} -> result
    end
  end

  def call(timestamp, user) do
    timestamp
    |> delete_records
    |> Event.broadcast("http-request-logs:deleted", user)
  end

  defp delete_records(%DateTime{} = timestamp) do
    result =
      HttpRequestLog
      |> where([el], el.inserted_at < ^timestamp)
      |> Repo.delete_all()

    case result do
      {:error, message} -> {:error, message}
      {total, _entries} -> {:ok, %{timestamp: timestamp, total: total}}
    end
  end

  defp delete_records(_), do: {:error, "Invalid timestamp"}
end
