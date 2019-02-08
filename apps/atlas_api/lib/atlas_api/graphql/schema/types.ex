defmodule AtlasApi.GraphQL.Schema.Types do
  use Absinthe.Schema.Notation
  use AtlasApi.GraphQL.Schema.Scalars

  object :info do
    field :release_branch, :string
    field :release_hash, :string
    field :release_version, :string
  end

  object :permission do
    field :id, :string
    field :description, :string
    field :name, :string
    field :slug, :string
  end

  object :role do
    field :id, :string
    field :description, :string
    field :name, :string
    field :slug, :string
  end

  object :session do
    field :token, :string
    field :token_creation, :string
    field :token_expiration, :string
    field :user, :user
  end

  object :user do
    field :id, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :name, :string
    field :inserted_at, :time
    field :updated_at, :time
    field :permissions, list_of(:permission)
    field :roles, list_of(:role)
  end
end
