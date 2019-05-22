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
    system_user = Application.fetch_env!(:artemis, :users)[:system_user]

    User
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(email: system_user.email)
  end
end
