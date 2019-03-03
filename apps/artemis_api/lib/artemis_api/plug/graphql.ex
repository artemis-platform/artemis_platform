defmodule ArtemisApi.Plug.GraphQL do
  use Plug.Builder

  plug Absinthe.Plug, schema: ArtemisApi.GraphQL.Schema
end
