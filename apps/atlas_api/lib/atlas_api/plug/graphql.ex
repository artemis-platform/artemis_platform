defmodule AtlasApi.Plug.GraphQL do
  use Plug.Builder

  plug Absinthe.Plug, schema: AtlasApi.GraphQL.Schema
end
