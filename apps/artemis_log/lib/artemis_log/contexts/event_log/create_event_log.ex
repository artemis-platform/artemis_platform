defmodule ArtemisLog.CreateEventLog do
  use ArtemisLog.Context

  alias ArtemisLog.EventLog
  alias ArtemisLog.Filter
  alias ArtemisLog.Repo

  def call(event, %{data: data, user: user}) do
    params = %{
      action: event,
      meta: Filter.call(data),
      user_id: user && Map.get(user, :id),
      user_name: user && Map.get(user, :name)
    }

    %EventLog{}
    |> EventLog.changeset(params)
    |> Repo.insert()
  end
end
