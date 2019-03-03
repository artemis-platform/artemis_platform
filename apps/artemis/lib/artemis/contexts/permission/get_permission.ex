defmodule Artemis.GetPermission do
  import Ecto.Query

  alias Artemis.Permission
  alias Artemis.Repo

  @default_preload []

  def call!(value, options \\ []) do
    get_record(value, options, &Repo.get_by!/2)
  end

  def call(value, options \\ []) do
    get_record(value, options, &Repo.get_by/2)
  end

  defp get_record(value, options, get_by) when not is_list(value) do
    get_record([id: value], options, get_by)
  end
  defp get_record(value, options, get_by) do
    Permission
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(value)
  end
end
