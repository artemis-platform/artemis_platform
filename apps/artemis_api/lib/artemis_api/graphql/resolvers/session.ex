defmodule ArtemisApi.GraphQL.Resolver.Session do
  alias Artemis.Event
  alias ArtemisApi.CreateSession
  alias ArtemisApi.GetUserByAuthProvider

  def create_session(params, _context) do
    case GetUserByAuthProvider.call(params) do
      {:ok, user} ->
        user
        |> CreateSession.call()
        |> Event.broadcast("session:created:api", user)

      error ->
        error
    end
  end
end
