defmodule ArtemisApi.Plug.GraphQLPublic do
  use Plug.Builder

  plug(Absinthe.Plug, schema: ArtemisApi.GraphQL.SchemaPublic)
end
