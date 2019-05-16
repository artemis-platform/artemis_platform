defmodule Artemis.ResetDemoData do
  @delete %{
    Artemis.Repo => [
      Artemis.AuthProvider,
      Artemis.Feature,
      Artemis.Permission,
      Artemis.Role,
      Artemis.User,
      Artemis.UserRole
    ]
    ArtemisLog.Repo => [
      ArtemisLog.EventLog
    ]
  }

  def call() do
    delete_all()
    seed_data()
  end

  defp delete_all do
    Enum.map(@delete, fn (repo, schemas) ->
      Enum.map(schemas, &repo.delete_all(&1))
    end)
  end

  defp seed_data do
    Artemis.Repo.Seeds.call()
  end
end
