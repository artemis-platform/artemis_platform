defmodule Atlas.GetUser do
  import Ecto.Query

  alias Atlas.Repo
  alias Atlas.User

  @default_by :id
  @default_preload []

  def call!(value, options \\ []) do
    get_record(value, options, &Repo.get_by!/2)
  end

  def call(value, options \\ []) do
    get_record(value, options, &Repo.get_by/2)
  end

  defp get_record(value, options, get_by) do
    key = Keyword.get(options, :by, @default_by)

    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.([{key, value}])
  end
end
