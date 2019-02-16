defmodule AtlasLog.GetEventLogTest do
  use AtlasLog.DataCase

  import AtlasLog.Factories

  alias AtlasLog.GetEventLog

  setup do
    event_log = insert(:event_log)

    {:ok, event_log: event_log}
  end

  describe "call" do
    test "returns nil event log not found" do
      invalid_id = 50000000

      assert GetEventLog.call(invalid_id) == nil
    end

    test "finds event log by id", %{event_log: event_log} do
      assert GetEventLog.call(event_log.id).id == event_log.id
    end

    test "finds event log keyword list", %{event_log: event_log} do
      assert GetEventLog.call(user_id: event_log.user_id, user_name: event_log.user_name).id == event_log.id
    end
  end

  describe "call!" do
    test "raises an exception event log not found" do
      invalid_id = 50000000

      assert_raise Ecto.NoResultsError, fn () ->
        GetEventLog.call!(invalid_id) == nil
      end
    end

    test "finds event log by id", %{event_log: event_log} do
      assert GetEventLog.call!(event_log.id).id == event_log.id
    end
  end
end
