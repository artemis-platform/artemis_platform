defmodule ArtemisApi.GraphQL.Resolver.User do
  import ArtemisApi.UserAccess

  alias Artemis.CreateUser
  alias Artemis.DeleteUser
  alias Artemis.GetUser
  alias Artemis.ListUsers
  alias Artemis.UpdateUser

  # Queries

  def list(params, context) do
    require_permission context, "users:list", fn () ->
      params = Map.put(params, :paginate, true)

      {:ok, ListUsers.call(params, get_user(context))}
    end
  end

  def get(%{id: id}, context) do
    require_permission context, "users:show", fn () ->
      {:ok, GetUser.call(id, get_user(context))}
    end
  end

  # Mutations

  def create(%{user: params}, context) do
    require_permission context, "users:create", fn () ->
      CreateUser.call(params, get_user(context))
    end
  end

  def update(%{id: id, user: params}, context) do
    require_permission context, "users:update", fn () ->
      UpdateUser.call(id, params, get_user(context))
    end
  end

  def delete(%{id: id}, context) do
    require_permission context, "users:delete", fn () ->
      DeleteUser.call(id, get_user(context))
    end
  end
end
