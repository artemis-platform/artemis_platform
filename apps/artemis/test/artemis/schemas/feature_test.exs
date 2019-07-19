defmodule Artemis.FeatureTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  describe "attributes - constraints" do
    test "slug must be unique" do
      existing = insert(:feature)

      assert_raise Ecto.ConstraintError, fn ->
        insert(:feature, slug: existing.slug)
      end
    end
  end
end
