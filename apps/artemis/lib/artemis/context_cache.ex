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

  defmacro __using__(options) do
    quote do
      import Artemis.ContextCache

      alias Artemis.CacheInstance

      @doc """
      Generic wrapper function to add caching around `call`
      """
      def cache(), do: call_with_cache([])
      def cache(arg1), do: call_with_cache([arg1])
      def cache(arg1, arg2), do: call_with_cache([arg1, arg2])
      def cache(arg1, arg2, arg3), do: call_with_cache([arg1, arg2, arg3])
      def cache(arg1, arg2, arg3, arg4), do: call_with_cache([arg1, arg2, arg3, arg4])

      # Helpers

      defp call_with_cache(args) do
        {:ok, _} = create_cache()

        getter = fn ->
          apply(__MODULE__, :call, args)
        end

        key = create_cache_key(args)

        Artemis.CacheInstance.fetch(__MODULE__, key, getter)
      end

      defp create_cache() do
        case CacheInstance.exists?(__MODULE__) do
          true ->
            {:ok, "Cache already exists"}

          false ->
            options = [
              cache_reset_events: Keyword.get(unquote(options), :cache_reset_events, []),
              module: __MODULE__
            ]

            Artemis.CacheSupervisor.start_child(options)
        end
      end

      defp create_cache_key(args) do
        %{
          other_args: get_non_user_args(args),
          user_permissions: get_user_permissions(args)
        }
      end

      defp get_user_permissions(args) do
        args
        |> get_user_arg()
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
