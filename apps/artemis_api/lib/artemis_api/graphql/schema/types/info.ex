defmodule ArtemisApi.GraphQL.Schema.Types.Info do
  use Absinthe.Schema.Notation

  alias ArtemisApi.GraphQL.Resolver

  # Queries

  object :info_queries do
    field :info, type: :info do
      resolve &Resolver.Info.info/2
    end
  end
end
