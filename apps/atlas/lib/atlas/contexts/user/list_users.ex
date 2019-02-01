defmodule Atlas.ListUsers do
  import Ecto.Query

  alias Atlas.Repo
  alias Atlas.User

  @default_preload []

  def call(options \\ []) do
    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.all()
  end
end
