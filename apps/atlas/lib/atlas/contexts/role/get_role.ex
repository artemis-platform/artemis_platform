defmodule Atlas.GetRole do
  import Ecto.Query

  alias Atlas.Role
  alias Atlas.Repo

  @default_preload []

  def call(id, options \\ []) do
    Role
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.get(id)
  end

  def call!(id, options \\ []) do
    Role
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.get!(id)
  end
end
