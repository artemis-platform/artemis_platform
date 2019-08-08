defmodule Artemis.AnonymizeUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.AnonymizeUser

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000

      assert_raise Artemis.Context.Error, fn ->
        AnonymizeUser.call!(invalid_id, Mock.system_user())
      end
    end

    test "anonymizes a record when passed valid params" do
      record = insert(:user)

      result = AnonymizeUser.call!(record, Mock.system_user())

      assert result.email =~ "anonymized-user-"
      assert result.first_name == nil
      assert result.last_name == nil
      assert result.name =~ "Anonymized User "
    end

    test "anonymizes a record when passed an id and valid params" do
      record = insert(:user)

      result = AnonymizeUser.call!(record.id, Mock.system_user())

      assert result.email =~ "anonymized-user-"
      assert result.first_name == nil
      assert result.last_name == nil
      assert result.name =~ "Anonymized User "
    end
  end

  describe "call" do
    test "returns an error when record not found" do
      invalid_id = 50_000_000

      {:error, _} = AnonymizeUser.call(invalid_id, Mock.system_user())
    end

    test "anonymizes a record when passed valid params" do
      record = insert(:user)

      {:ok, result} = AnonymizeUser.call(record, Mock.system_user())

      assert result.email =~ "anonymized-user-"
      assert result.first_name == nil
      assert result.last_name == nil
      assert result.name =~ "Anonymized User "
    end

    test "anonymizes a record when passed an id and valid params" do
      record = insert(:user)

      {:ok, result} = AnonymizeUser.call(record.id, Mock.system_user())

      assert result.email =~ "anonymized-user-"
      assert result.first_name == nil
      assert result.last_name == nil
      assert result.name =~ "Anonymized User "
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, user} = AnonymizeUser.call(insert(:user), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "user:anonymized",
        payload: %{
          data: ^user
        }
      }
    end
  end
end
