defmodule Artemis.GetAuthProviderTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetAuthProvider

  setup do
    auth_provider = insert(:auth_provider)

    {:ok, auth_provider: auth_provider}
  end

  describe "call" do
    test "returns nil auth_provider not found" do
      invalid_id = 50000000

      assert GetAuthProvider.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds auth provider by id", %{auth_provider: auth_provider} do
      assert GetAuthProvider.call(auth_provider.id, Mock.system_user()) == auth_provider
    end

    test "finds user keyword list", %{auth_provider: auth_provider} do
      assert GetAuthProvider.call([type: auth_provider.type, uid: auth_provider.uid], Mock.system_user()) == auth_provider
    end
  end

  describe "call!" do
    test "raises an exception auth_provider not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetAuthProvider.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds auth provider by id", %{auth_provider: auth_provider} do
      assert GetAuthProvider.call!(auth_provider.id, Mock.system_user()) == auth_provider
    end
  end
end
