defmodule Atlas.Repo.Helpers do
  alias Atlas.Repo

  require Logger

  def with_transaction(fun, opts \\ []) do
    Repo.transaction(fn ->
      case fun.() do
        {:error, message} -> Repo.rollback(message)
        {:ok, value} -> value
        other -> other
      end
    end, opts)
  rescue
    error ->
      Logger.debug "Transaction error " <> inspect(error)
      raise error
  end
end
