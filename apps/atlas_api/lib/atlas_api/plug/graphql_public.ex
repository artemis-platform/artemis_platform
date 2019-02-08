defmodule AtlasApi.Plug.GraphQLPublic do
  use Plug.Builder

  plug Absinthe.Plug, schema: AtlasApi.GraphQL.SchemaPublic
end
