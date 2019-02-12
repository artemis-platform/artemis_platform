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

      assert ListFeatures.call() == [feature]
    end

    test "returns list of features" do
      count = 3
      insert_list(count, :feature)

      assert length(ListFeatures.call()) == count
    end
  end
end
