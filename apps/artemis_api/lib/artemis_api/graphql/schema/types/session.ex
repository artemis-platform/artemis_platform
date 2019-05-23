defmodule ArtemisApi.GraphQL.Schema.Types.Session do
  use Absinthe.Schema.Notation

  alias ArtemisApi.GraphQL.Resolver

  # Mutations

  object :session_mutations do
    field :create_session, type: :session do
      arg(:provider, non_null(:string))
      arg(:client_key, :string)
      arg(:client_secret, :string)
      arg(:code, :string)
      arg(:redirect_uri, :string)

      resolve(&Resolver.Session.create_session/2)
    end
  end
end
