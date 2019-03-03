defmodule Artemis.GetSystemUser do
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.User

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
    |> get_by.(email: Application.fetch_env!(:artemis, :system_user).email)
  end
end
