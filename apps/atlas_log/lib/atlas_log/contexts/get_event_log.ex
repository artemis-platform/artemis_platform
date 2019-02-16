defmodule AtlasLog.GetEventLog do
  alias AtlasLog.EventLog
  alias AtlasLog.Repo

  def call!(value) do
    get_record(value, &Repo.get_by!/2)
  end

  def call(value) do
    get_record(value, &Repo.get_by/2)
  end

  defp get_record(value, get_by) when not is_list(value) do
    get_record([id: value], get_by)
  end
  defp get_record(value, get_by) do
    EventLog
    |> get_by.(value)
  end
end
