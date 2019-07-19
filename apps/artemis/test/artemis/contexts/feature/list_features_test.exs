defmodule Artemis.ListFeaturesTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListFeatures
  alias Artemis.Repo
  alias Artemis.Feature

  setup do
    Repo.delete_all(Feature)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no features exist" do
      assert ListFeatures.call(Mock.system_user()) == []
    end

    test "returns existing feature" do
      feature = insert(:feature)

      assert ListFeatures.call(Mock.system_user()) == [feature]
    end

    test "returns a list of features" do
      count = 3
      insert_list(count, :feature)

      features = ListFeatures.call(Mock.system_user())

      assert length(features) == count
    end
  end

  describe "call - params" do
    setup do
      feature = insert(:feature)

      {:ok, feature: feature}
    end

    test "order" do
      insert_list(3, :feature)

      params = %{order: "name"}
      ascending = ListFeatures.call(params, Mock.system_user())

      params = %{order: "-name"}
      descending = ListFeatures.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListFeatures.call(params, Mock.system_user())
        |> Map.from_struct()
        |> Map.keys()

      pagination_keys = [
        :entries,
        :page_number,
        :page_size,
        :total_entries,
        :total_pages
      ]

      assert response_keys == pagination_keys
    end

    test "query - search" do
      insert(:feature, name: "Four Six", slug: "four-six")
      insert(:feature, name: "Four Two", slug: "four-two")
      insert(:feature, name: "Five Six", slug: "five-six")

      user = Mock.system_user()
      features = ListFeatures.call(user)

      assert length(features) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      features = ListFeatures.call(params, user)

      assert length(features) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "four-"
      }

      features = ListFeatures.call(params, user)

      assert length(features) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      features = ListFeatures.call(params, user)

      assert length(features) == 0
    end
  end

  describe "cache" do
    setup do
      ListFeatures.reset_cache()
      ListFeatures.call_with_cache(Mock.system_user())

      {:ok, []}
    end

    test "uses default cache key callback" do
      key = ListFeatures.call_with_cache(Mock.system_user()).key

      assert is_map(key)
      assert Map.keys(key) == [:other_args, :user_permissions]
      assert key.other_args == []

      params = %{
        paginate: true
      }

      key = ListFeatures.call_with_cache(params, Mock.system_user()).key

      assert is_map(key)
      assert Map.keys(key) == [:other_args, :user_permissions]
      assert key.other_args == [params]
    end

    test "uses default context cache options" do
      defaults = Artemis.CacheInstance.default_cachex_options()
      cachex_options = Artemis.CacheInstance.get_cachex_options(ListFeatures)

      assert cachex_options[:expiration] == Keyword.fetch!(defaults, :expiration)
      assert cachex_options[:limit] == Keyword.fetch!(defaults, :limit)
    end

    test "returns a cached result" do
      initial_call = ListFeatures.call_with_cache(Mock.system_user())

      assert initial_call.__struct__ == Artemis.CacheInstance.CacheEntry
      assert is_list(initial_call.data)
      assert initial_call.inserted_at != nil
      assert initial_call.key != nil

      cache_hit = ListFeatures.call_with_cache(Mock.system_user())

      assert is_list(cache_hit.data)
      assert cache_hit.inserted_at != nil
      assert cache_hit.inserted_at == initial_call.inserted_at
      assert cache_hit.key != nil

      params = %{
        paginate: true
      }

      different_key = ListFeatures.call_with_cache(params, Mock.system_user())

      assert different_key.data.__struct__ == Scrivener.Page
      assert is_list(different_key.data.entries)
      assert different_key.inserted_at != nil
      assert different_key.key != nil
    end
  end
end
