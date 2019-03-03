defmodule ArtemisLog.Mock do
  alias Artemis.Repo
  alias Artemis.User

  def system_user() do
    params = Application.fetch_env!(:artemis, :system_user)

    Repo.get_by(User, email: params.email)
  end
end
