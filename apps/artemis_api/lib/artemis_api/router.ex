defmodule ArtemisApi.Router do
  use ArtemisApi, :router

  if Application.get_env(:artemis_api, :graphiql, false) do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: ArtemisApi.GraphQL.Schema
  end

  scope "/" do
    pipe_through ArtemisApi.Plug.ClientCredentials
    pipe_through ArtemisApi.Plug.GuardianAuth
    pipe_through ArtemisApi.Plug.GraphQLContext
    forward "/data", ArtemisApi.Plug.GraphQL
  end

  scope "/" do
    forward "/health_check", ArtemisApi.Plug.HealthCheck
    forward "/", ArtemisApi.Plug.GraphQLPublic
  end
end
