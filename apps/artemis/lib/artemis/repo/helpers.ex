defmodule Artemis.Repo.Helpers do
  alias Artemis.Repo

  import Artemis.Helpers

  require Logger

  @doc """
  Adds default pagination params.
  """
  def pagination_params(params, options \\ []) do
    params
    |> keys_to_strings()
    |> Map.put_new("page_size", Keyword.get(options, :default_page_size, 10))
    |> Map.put_new("page", Map.get(params, "page_number", 1))
  end

  @doc """
  Wraps the passed function in a database transaction, rolling back when either
  an exception is raised or `{:error, _}` tuple is return.
  """
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
