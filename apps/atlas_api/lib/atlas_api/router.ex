defmodule AtlasApi.Router do
  use AtlasApi, :router

  if Application.get_env(:atlas_api, :graphiql, false) do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: AtlasApi.GraphQL.Schema
  end

  scope "/" do
    pipe_through AtlasApi.Plug.GuardianAuth
    pipe_through AtlasApi.Plug.GraphQLContext
    forward "/data", AtlasApi.Plug.GraphQL
  end

  scope "/" do
    forward "/health_check", AtlasApi.Plug.HealthCheck
    forward "/", AtlasApi.Plug.GraphQLPublic
  end
end
