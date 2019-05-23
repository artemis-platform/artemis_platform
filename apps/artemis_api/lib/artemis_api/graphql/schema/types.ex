defmodule ArtemisApi.GraphQL.Schema.Types do
  use Absinthe.Schema.Notation
  use ArtemisApi.GraphQL.Schema.Scalars

  # Paginated Objects

  object :paginated_users do
    field(:entries, list_of(:user))
    field(:page_number, :integer)
    field(:page_size, :integer)
    field(:total_entries, :integer)
    field(:total_pages, :integer)
  end

  # Schema Objects

  object :info do
    field(:release_branch, :string)
    field(:release_hash, :string)
    field(:release_version, :string)
  end

  object :permission do
    field(:id, :string)
    field(:description, :string)
    field(:name, :string)
    field(:slug, :string)
  end

  object :role do
    field(:id, :string)
    field(:description, :string)
    field(:name, :string)
    field(:slug, :string)
  end

  object :session do
    field(:token, :string)
    field(:token_creation, :string)
    field(:token_expiration, :string)
    field(:user, :user)
  end

  object :user do
    field(:id, :string)
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:name, :string)
    field(:inserted_at, :time)
    field(:updated_at, :time)
    field(:permissions, list_of(:permission))
    field(:roles, list_of(:role))
  end
end
