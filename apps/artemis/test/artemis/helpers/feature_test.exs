defmodule Artemis.Helpers.FeatureTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.Helpers.Feature
  alias Artemis.ListFeatures

  setup do
    ListFeatures.reset_cache()

    {:ok, []}
  end

  describe "active?" do
    test "returns false when passed an inactive record" do
      feature = insert(:feature, active: false)

      assert Feature.active?(feature) == false
    end

    test "returns false when passed an inactive slug" do
      feature = insert(:feature, active: false)

      assert Feature.active?(feature.slug) == false
    end

    test "returns true when passed an active record" do
      feature = insert(:feature, active: true)

      assert Feature.active?(feature) == true
    end

    test "returns true when passed an active slug" do
      feature = insert(:feature, active: true)

      assert Feature.active?(feature.slug) == true
    end
  end
end
