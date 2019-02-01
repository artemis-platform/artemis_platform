defmodule Atlas.ListPermissions do
  import Ecto.Query

  alias Atlas.Permission
  alias Atlas.Repo

  @default_preload []

  def call(options \\ []) do
    Permission
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.all()
  end
end
