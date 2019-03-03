defmodule Artemis.FeatureTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Feature

  describe "attributes - constraints" do
    test "slug must be unique" do
      existing = insert(:feature)

      assert_raise Ecto.ConstraintError, fn () ->
        insert(:feature, slug: existing.slug)
      end
    end
  end

  describe "queries - active?" do
    test "returns false when not active" do
      feature = insert(:feature)

      assert Feature.active?(feature) == false
    end

    test "returns true when active" do
      feature = insert(:feature, active: true)

      assert Feature.active?(feature) == true
    end
  end
end
