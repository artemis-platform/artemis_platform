defmodule Atlas.GetUser do
  import Ecto.Query

  alias Atlas.User
  alias Atlas.Repo

  @default_preload []

  def call(id, options \\ []) do
    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.get(id)
  end

  def call!(id, options \\ []) do
    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.get!(id)
  end
end
