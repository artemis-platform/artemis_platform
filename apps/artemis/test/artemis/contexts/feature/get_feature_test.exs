defmodule Artemis.GetFeatureTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetFeature

  setup do
    feature = insert(:feature)

    {:ok, feature: feature}
  end

  describe "call" do
    test "returns nil feature not found" do
      invalid_id = 50000000

      assert GetFeature.call(invalid_id) == nil
    end

    test "finds feature by id", %{feature: feature} do
      assert GetFeature.call(feature.id) == feature
    end

    test "finds user keyword list", %{feature: feature} do
      assert GetFeature.call(name: feature.name, slug: feature.slug) == feature
    end
  end

  describe "call!" do
    test "raises an exception feature not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetFeature.call!(invalid_id) == nil
      end
    end

    test "finds feature by id", %{feature: feature} do
      assert GetFeature.call!(feature.id) == feature
    end
  end
end
