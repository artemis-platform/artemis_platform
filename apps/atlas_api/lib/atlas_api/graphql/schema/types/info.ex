defmodule AtlasApi.GraphQL.Schema.Types.Info do
  use Absinthe.Schema.Notation

  alias AtlasApi.GraphQL.Resolver

  # Queries

  object :info_queries do
    field :info, type: :info do
      resolve &Resolver.Info.info/2
    end
  end
end
