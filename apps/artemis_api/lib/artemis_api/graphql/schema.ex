defmodule ArtemisApi.GraphQL.Schema do
  @moduledoc """
  GraphQL queries and mutations for authenticated users
  """
  use Absinthe.Schema

  import_types(ArtemisApi.GraphQL.Schema.Types)
  import_types(ArtemisApi.GraphQL.Schema.Types.Info)
  import_types(ArtemisApi.GraphQL.Schema.Types.User)

  query do
    import_fields(:info_queries)
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end

  def middleware(middleware, _field, %{identifier: :mutation}),
    do: middleware ++ [ArtemisApi.GraphQL.Middleware.HandleChangesetErrors]

  def middleware(middleware, _field, _object), do: middleware
end
