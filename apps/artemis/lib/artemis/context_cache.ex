defmodule Artemis.ContextCache do
  @moduledoc """
  Extends Context modules with cache functions

  ## Cache Keys

  A single cache instance can store many values under different keys. By
  default, a simple cache key based on the passed parameters is used.

  For example, these calls are stored under different keys:

      MyApp.ExampleContext.call_with_cache(%{page: 1})
      MyApp.ExampleContext.call_with_cache(%{page: 200})

  By default, the simple cache key treats all users equally. As long as the
  parameters match, the same data is returned:

      MyApp.ExampleContext.call_with_cache(%{page: 1}, user_1)
      MyApp.ExampleContext.call_with_cache(%{page: 1}, user_2)

  Typically, permissions are checked before a cache is called. And that
  upstream code determines whether a user has access to the context or not.

  But there are cases where the user's permissions are also used within the
  context to return different results.

  For example, an admin user may be able to see a list of all resources, where
  normal users can only see resources related to their user.

  In these cases, a more complex cache key that includes the user's
  permissions is needed.

  ### Complex and Custom Cache Keys

  There are two options to implement a cache key that takes into account the
  user's permission.

  The first way is to use the built-in key generator by passing the
  `cache_key` option:

      defmodule MyApp.ExampleContext do
        use MyApp.ContextCache,
          cache_key: :complex
      end

  This generic built-in collects all of the users permissions and includes them in the
  cache key. While effective, the same data may be cached under different keys
  because the built-in function does not understand which of the user's many
  permissions determine the context output.

  A better approach is to define a custom cache option:

      defmodule MyApp.ExampleContext do
        use MyApp.ContextCache,
          cache_key: &custom_cache_key/1

        def custom_cache_key(args) do
          # custom code here
        end
      end

  The custom cache key can filter user permissions to the exact ones used
  within the context. This fine-grained control can ensure users only have
  access to the proper data while also minimizing the amount of duplicate
  values in the cache.
  """

  defmacro __using__(options) do
    quote do
      import Artemis.ContextCache

      alias Artemis.CacheInstance
      alias Artemis.Repo

      @doc """
      Generic wrapper function to add caching around `call`
      """
      def call_with_cache(), do: fetch_cached([])
      def call_with_cache(arg1), do: fetch_cached([arg1])
      def call_with_cache(arg1, arg2), do: fetch_cached([arg1, arg2])
      def call_with_cache(arg1, arg2, arg3), do: fetch_cached([arg1, arg2, arg3])
      def call_with_cache(arg1, arg2, arg3, arg4), do: fetch_cached([arg1, arg2, arg3, arg4])
      def call_with_cache(arg1, arg2, arg3, arg4, arg5), do: fetch_cached([arg1, arg2, arg3, arg4, arg5])

      @doc """
      Clear all values from cache. Returns successfully if cache is not started.
      """
      def reset_cache() do
        case Artemis.CacheInstance.started?(__MODULE__) do
          true -> {:ok, Artemis.CacheInstance.reset(__MODULE__)}
          false -> {:ok, :cache_not_started}
        end
      end

      # Helpers

      defp fetch_cached(args) do
        {:ok, _} = create_cache()

        getter = fn ->
          apply(__MODULE__, :call, args)
        end

        key = get_cache_key(args)

        Artemis.CacheInstance.fetch(__MODULE__, key, getter)
      rescue
        error in MatchError -> handle_match_error(args, error)
      end

      defp handle_match_error(args, %MatchError{term: {:error, {:already_started, _}}}) do
        # The CacheInstance contains two linked processes, a cache GenServer and a
        # Cachex instance. The GenServer starts a linked Cachex instance on initialization.
        #
        # There is a race condition when the GenServer is started and the Cachex instance
        # is still in the process of starting. If multiple requests are sent at
        # the same time, it may result in multiple Cachex instances being started. The
        # first instance to complete will succeed and all other requests will
        # fail with an `:already_started` # error message.
        #
        # Since a Cachex instance is now running, resending the request to the
        # GenServer will succeed.
        #
        fetch_cached(args)
      end

      defp handle_match_error(args, _error) do
        # The CacheInstance contains two linked processes, a cache GenServer and a
        # Cachex instance. When a CacheInstance is reset, the cache GenServer is
        # stopped. Because they are linked, shortly after the Cachex instance is also
        # stopped.
        #
        # There is a race condition when the GenServer is stopped and the Cachex instance
        # is still in the process of stopping. If a new cache request is received during
        # that window of time, the new cache GenServer will fail when trying to start a
        # linked Cachex instance because the Cachex registered name is unavailable.
        #
        # This race condition is primarily hit in test scenarios, but could occur in
        # production under a heavy request load.
        #
        # Instead of trying to resolve the race condition, let it crash. Return a valid
        # uncached result in the meantime. Future requests after this window closes will
        # successfully create a dynamic cache.
        #
        %Artemis.CacheInstance.CacheEntry{data: apply(__MODULE__, :call, args)}
      end

      defp create_cache() do
        case CacheInstance.exists?(__MODULE__) do
          true ->
            {:ok, "Cache already exists"}

          false ->
            child_options = [
              cache_reset_on_events: Keyword.get(unquote(options), :cache_reset_on_events, []),
              cachex_options: Keyword.get(unquote(options), :cachex_options, []),
              module: __MODULE__
            ]

            Artemis.CacheSupervisor.start_child(child_options)
        end
      end

      defp get_cache_key(args) do
        case Keyword.get(unquote(options), :cache_key, :simple) do
          :complex -> get_built_in_cache_key_complex(args)
          :simple -> get_built_in_cache_key_simple(args)
          custom -> custom.(args)
        end
      end

      defp get_built_in_cache_key_complex(args) do
        %{
          other_args: get_non_user_args(args),
          user_permissions: get_user_permissions(args)
        }
      end

      defp get_built_in_cache_key_simple(args), do: get_non_user_args(args)

      defp get_user_permissions(args) do
        args
        |> get_user_arg()
        |> Repo.preload([:permissions])
        |> Map.get(:permissions)
        |> Enum.map(& &1.slug)
        |> Enum.sort()
      end

      defp get_user_arg(args) do
        default = %Artemis.User{permissions: []}

        args
        |> Enum.reverse()
        |> Enum.find(default, &user?(&1))
      end

      defp get_non_user_args(args) do
        index =
          args
          |> Enum.reverse()
          |> Enum.find_index(&user?(&1))

        case index do
          nil ->
            args

          _ ->
            args
            |> Enum.reverse()
            |> List.delete_at(index)
            |> Enum.reverse()
        end
      end

      defp user?(value), do: is_map(value) && value.__struct__ == Artemis.User
    end
  end
end
