defmodule AtlasApi.GraphQL.SchemaPublic do
  @moduledoc """
  GraphQL queries and mutations without authentication
  """
  use Absinthe.Schema

  import_types AtlasApi.GraphQL.Schema.Types
  import_types AtlasApi.GraphQL.Schema.Types.Info
  import_types AtlasApi.GraphQL.Schema.Types.Session

  query do
    import_fields :info_queries
  end

  mutation do
    import_fields :session_mutations
  end

  def middleware(middleware, _field, %{identifier: :mutation}), do: middleware ++ [AtlasApi.GraphQL.Middleware.HandleChangesetErrors]
  def middleware(middleware, _field, _object), do: middleware
end
