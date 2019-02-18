defmodule Atlas.Mock do
  alias Atlas.Repo
  alias Atlas.User

  def system_user() do
    params = Application.fetch_env!(:atlas, :system_user)

    Repo.get_by(User, email: params.email)
  end
end
