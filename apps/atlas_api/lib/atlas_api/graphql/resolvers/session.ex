defmodule AtlasApi.GraphQL.Resolver.Session do
  alias Atlas.Event
  alias AtlasApi.CreateSession
  alias AtlasApi.GetUserByAuthProvider

  def create_session(params, _context) do
    case GetUserByAuthProvider.call(params) do
      {:ok, user} -> user
        |> CreateSession.call
        |> Event.broadcast("session:created:api", user)
      error -> error
    end
  end
end

