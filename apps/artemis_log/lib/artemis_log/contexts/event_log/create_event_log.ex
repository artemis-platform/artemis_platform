defmodule ArtemisLog.CreateEventLog do
  use ArtemisLog.Context

  alias ArtemisLog.EventLog
  alias ArtemisLog.Filter
  alias ArtemisLog.Repo

  def call(event, %{data: data, meta: meta, user: user}) do
    event
    |> get_create_params(data, meta, user)
    |> insert_record()
    |> Artemis.Event.broadcast("event-log:created", user)
  end

  defp get_create_params(event, data, meta, user) do
    %{
      action: event,
      data: Filter.call(data),
      meta: meta,
      resource_id: get_resource_id(data),
      resource_type: get_resource_type(data),
      session_id: user && Map.get(user, :session_id),
      user_id: user && Map.get(user, :id),
      user_name: user && Map.get(user, :name)
    }
  end

  defp get_resource_type(%{__struct__: struct}) do
    struct
    |> Artemis.Helpers.module_name()
    |> Artemis.Helpers.to_string()
  end

  defp get_resource_type(_), do: nil

  defp get_resource_id(%{id: id}), do: Artemis.Helpers.to_string(id)
  defp get_resource_id(%{_id: id}), do: Artemis.Helpers.to_string(id)
  defp get_resource_id(_), do: nil

  defp insert_record(params) do
    %EventLog{}
    |> EventLog.changeset(params)
    |> Repo.insert()
  end
end
