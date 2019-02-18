defmodule Atlas.GetSystemUser do
  import Ecto.Query

  alias Atlas.Repo
  alias Atlas.User

  @default_preload [:permissions]

  def call!(options \\ []) do
    get_record(options, &Repo.get_by!/2)
  end

  def call(options \\ []) do
    get_record(options, &Repo.get_by/2)
  end

  defp get_record(options, get_by) do
    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(email: Application.fetch_env!(:atlas, :system_user).email)
  end
end
