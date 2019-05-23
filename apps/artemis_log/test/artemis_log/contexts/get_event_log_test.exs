defmodule ArtemisLog.GetEventLogTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.GetEventLog

  setup do
    event_log = insert(:event_log)

    {:ok, event_log: event_log}
  end

  describe "call" do
    test "returns nil event log not found" do
      invalid_id = 50_000_000

      assert GetEventLog.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds event log by id", %{event_log: event_log} do
      assert GetEventLog.call(event_log.id, Mock.system_user()).id == event_log.id
    end

    test "finds event log keyword list", %{event_log: event_log} do
      values = [user_id: event_log.user_id, user_name: event_log.user_name]
      user = Mock.system_user()

      assert GetEventLog.call(values, user).id == event_log.id
    end
  end

  describe "call!" do
    test "raises an exception event log not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetEventLog.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds event log by id", %{event_log: event_log} do
      assert GetEventLog.call!(event_log.id, Mock.system_user()).id == event_log.id
    end
  end
end
