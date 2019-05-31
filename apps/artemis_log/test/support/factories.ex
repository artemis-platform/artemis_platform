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

  def http_request_log_factory do
    %ArtemisLog.HttpRequestLog{
      endpoint: Faker.Internet.slug(),
      node: Faker.Internet.slug(),
      path: "/#{Faker.Internet.slug()}",
      query_string: "key=#{Faker.Internet.slug()}",
      session_id: Faker.UUID.v4(),
      user_id: 1,
      user_name: Faker.Name.name()
    }
  end
end
