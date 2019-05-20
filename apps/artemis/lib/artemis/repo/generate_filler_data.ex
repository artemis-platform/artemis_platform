defmodule Artemis.Repo.GenerateFillerData do
  import Artemis.Factories

  alias Artemis.GetSystemUser
  alias Artemis.Repo
  alias Artemis.Role

  @moduledoc """
  Generate consistent data for development, QA, test, and demo environments.

  Requires a verification phrase to be passed to prevent accidental execution
  in a production environment.
  """

  @verification_phrase "confirming-generation-of-filler-data"

  def call(verification_phrase) do
    case verification_phrase == @verification_phrase do
      true -> {:ok, generate_data()}
      false -> {:error, "Verification phrase required"}
    end
  end

  defp generate_data do
    system_user = GetSystemUser.call!()

    generate_users(system_user)
  end

  defp generate_users(system_user) do
    users = insert_list(30, :user)
    default_role = Repo.get_by(Role, slug: "default")

    Enum.map(users, fn (user) ->
      insert(:user_role, created_by: system_user, role: default_role, user: user)
    end)

    users
  end
end
