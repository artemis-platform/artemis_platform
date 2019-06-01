defmodule ArtemisLog.CreateHttpRequestLog do
  use ArtemisLog.Context

  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  def call(%{data: data, user: user}) do
    params =
      data
      |> Map.put(:session_id, user && Map.get(user, :session_id))
      |> Map.put(:user_id, user && Map.get(user, :id))
      |> Map.put(:user_name, user && Map.get(user, :name))

    %HttpRequestLog{}
    |> HttpRequestLog.changeset(params)
    |> Repo.insert()
  end
end
