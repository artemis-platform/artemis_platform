defmodule ArtemisApi.GraphQL.Schema.Types.User do
  use Absinthe.Schema.Notation

  alias ArtemisApi.GraphQL.Resolver

  # Queries

  input_object :user_filter_params do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:name, :string)
  end

  object :user_queries do
    field :list_users, :paginated_users do
      arg(:filters, :user_filter_params)
      arg(:page_number, :string)
      arg(:page_size, :string)

      resolve(&Resolver.User.list/2)
    end

    field :get_user, type: :user do
      arg(:id, non_null(:string))

      resolve(&Resolver.User.get/2)
    end
  end

  # Mutations

  input_object :user_params do
    field(:email, non_null(:string))
    field(:name, non_null(:string))
    field(:first_name, :string)
    field(:last_name, :string)
  end

  object :user_mutations do
    field :create_user, type: :user do
      arg(:user, :user_params)

      resolve(&Resolver.User.create/2)
    end

    field :update_user, type: :user do
      arg(:id, non_null(:string))
      arg(:user, :user_params)

      resolve(&Resolver.User.update/2)
    end

    field :delete_user, type: :user do
      arg(:id, non_null(:string))

      resolve(&Resolver.User.delete/2)
    end
  end
end
