defmodule AtlasWeb.Mock do
  alias Atlas.Repo
  alias Atlas.User

  def root_user() do
    params = Application.fetch_env!(:atlas, :root_user)

    Repo.get_by(User, email: params.email)
  end
end
