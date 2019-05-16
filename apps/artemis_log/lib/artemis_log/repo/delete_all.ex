defmodule ArtemisLog.Repo.DeleteAll do
  @schemas [
    ArtemisLog.EventLog
  ]
  @verification_phrase "confirming-deletion-of-all-database-data"

  def call(verification_phrase) do
    case verification_phrase == @verification_phrase do
      true -> {:ok, delete_all()}
      false -> {:error, "Verification phrase required"}
    end
  end

  defp delete_all do
    Enum.map(@schemas, &ArtemisLog.Repo.delete_all(&1))
  end
end
