defmodule ArtemisLog.GetHttpRequestLog do
  use ArtemisLog.Context

  import Ecto.Query

  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  def call!(value, user) do
    get_record(value, user, &Repo.get_by!/2)
  end

  def call(value, user) do
    get_record(value, user, &Repo.get_by/2)
  end

  defp get_record(value, user, get_by) when not is_list(value) do
    get_record([id: value], user, get_by)
  end

  defp get_record(value, user, get_by) do
    HttpRequestLog
    |> restrict_access(user)
    |> get_by.(value)
  end

  defp restrict_access(query, user) do
    cond do
      has?(user, "http-request-logs:access:all") -> query
      has?(user, "http-request-logs:access:self") -> where(query, [el], el.user_id == ^user.id)
      true -> where(query, [el], is_nil(el.id))
    end
  end
end
