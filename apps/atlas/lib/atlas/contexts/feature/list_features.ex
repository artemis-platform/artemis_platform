defmodule Atlas.ListFeatures do
  import Ecto.Query

  alias Atlas.Feature
  alias Atlas.Repo

  @default_preload []

  def call(options \\ []) do
    Feature
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> Repo.all()
  end
end
