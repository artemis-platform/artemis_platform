defmodule Atlas.ListFeaturesTest do
  use Atlas.DataCase

  import Atlas.Factories

  alias Atlas.ListFeatures
  alias Atlas.Repo
  alias Atlas.Feature

  setup do
    Repo.delete_all(Feature)

    {:ok, []}
  end

  describe "call" do

    test "returns empty list when no features exist" do
      assert ListFeatures.call() == []
    end

    test "returns existing feature" do
      feature = insert(:feature)

      assert ListFeatures.call()  == [feature]
    end

    test "returns a list of features" do
      count = 3
      insert_list(count, :feature)

      features = ListFeatures.call()

      assert length(features) == count
    end
  end

  describe "call - params" do
    setup do
      feature = insert(:feature)

      {:ok, feature: feature}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys = ListFeatures.call(params)
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
  end
end
