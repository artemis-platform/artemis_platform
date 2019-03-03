defmodule ArtemisLog.Factories do
  use ExMachina.Ecto, repo: ArtemisLog.Repo

  # Factories

  def event_log_factory do
    %ArtemisLog.EventLog{
      action: Faker.Internet.slug(),
      meta: %{test: "data"},
      user_id: 1,
      user_name: Faker.Name.name()
    }
  end
end
