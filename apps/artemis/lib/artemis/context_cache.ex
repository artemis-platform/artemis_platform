defmodule Artemis.ContextCache do
  @moduledoc """
  Extends Context modules with cache functions

  ## Cache Granularity

  By default, results will be stored under a highly granular cache key.
  Consisting of two parts:

  - User permissions. Ensures only users who share the same permissions
    can read cache values.

  - All other passed arguments. Ensures arguments like a resource id or
    options like pagination page number are treated as distinct entries

  """

  @callback get_cache_key(any()) :: any()
  @optional_callbacks get_cache_key: 1

  defmacro __using__(options) do
    quote do
      import Artemis.ContextCache

      alias Artemis.CacheInstance
      alias Artemis.Repo

      @behaviour Artemis.ContextCache

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
        _ in MatchError -> %Artemis.CacheInstance.CacheEntry{data: apply(__MODULE__, :call, args)}
      end

      defp create_cache() do
        case CacheInstance.exists?(__MODULE__) do
          true ->
            {:ok, "Cache already exists"}

          false ->
            options = [
              cache_reset_on_events: Keyword.get(unquote(options), :cache_reset_on_events, []),
              cachex_options: Keyword.get(unquote(options), :cachex_options, []),
              module: __MODULE__
            ]

            Artemis.CacheSupervisor.start_child(options)
        end
      end

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

      # Callbacks

      def get_cache_key(args) do
        %{
          other_args: get_non_user_args(args),
          user_permissions: get_user_permissions(args)
        }
      end

      # Allow defined `@callback`s to be overwritten

      defoverridable Artemis.ContextCache
    end
  end
end
