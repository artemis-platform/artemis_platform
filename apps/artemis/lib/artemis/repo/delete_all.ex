defmodule Artemis.Repo.DeleteAll do
  @moduledoc """
  Delete all application data from the database.

  Requires a verification phrase to be passed to prevent accidental execution.
  """

  @schemas [
    Artemis.AuthProvider,
    Artemis.Feature,
    Artemis.Permission,
    Artemis.Role,
    Artemis.User,
    Artemis.UserRole
  ]
  @verification_phrase "confirming-deletion-of-all-database-data"

  def call(verification_phrase) do
    case verification_phrase == @verification_phrase do
      true -> {:ok, delete_all()}
      false -> {:error, "Action requires valid verification phrase to be passed"}
    end
  end

  defp delete_all do
    Enum.map(@schemas, &Artemis.Repo.delete_all(&1))
  end
end
