defmodule Atlas.ListRoles do
  import Ecto.Query

  alias Atlas.Repo
  alias Atlas.Role

  @default_preload []

  def call(options \\ []) do
    Role
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.all()
  end
end
