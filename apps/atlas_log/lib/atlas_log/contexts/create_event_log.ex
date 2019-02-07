defmodule AtlasLog.CreateEventLog do
  alias AtlasLog.EventLog
  alias AtlasLog.Filter
  alias AtlasLog.Repo

  def call(event, %{data: data, user: user}) do
    params = %{
      action: event,
      meta: Filter.call(data),
      user_id: user.id,
      user_name: user.name
    }

    %EventLog{}
    |> EventLog.changeset(params)
    |> Repo.insert
  end
end
