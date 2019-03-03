defmodule Artemis.UpdateFeatureTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateFeature

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50000000
      params = params_for(:feature)

      assert_raise Artemis.Context.Error, fn () ->
        UpdateFeature.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      feature = insert(:feature)
      params = %{}

      updated = UpdateFeature.call!(feature, params, Mock.system_user())

      assert updated.name == feature.name
    end

    test "updates a record when passed valid params" do
      feature = insert(:feature)
      params = params_for(:feature)

      updated = UpdateFeature.call!(feature, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      feature = insert(:feature)
      params = params_for(:feature)

      updated = UpdateFeature.call!(feature.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50000000
      params = params_for(:feature)

      {:error, _} = UpdateFeature.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      feature = insert(:feature)
      params = %{}

      {:ok, updated} = UpdateFeature.call(feature, params, Mock.system_user())

      assert updated.name == feature.name
    end

    test "updates a record when passed valid params" do
      feature = insert(:feature)
      params = params_for(:feature)

      {:ok, updated} = UpdateFeature.call(feature, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      feature = insert(:feature)
      params = params_for(:feature)

      {:ok, updated} = UpdateFeature.call(feature.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      feature = insert(:feature)
      params = params_for(:feature)

      {:ok, updated} = UpdateFeature.call(feature, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "feature:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
