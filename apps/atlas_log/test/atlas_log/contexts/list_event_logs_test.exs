defmodule AtlasLog.ListEventLogsTest do
  use AtlasLog.DataCase

  import AtlasLog.Factories

  alias AtlasLog.ListEventLogs
  alias AtlasLog.Repo
  alias AtlasLog.EventLog

  setup do
    Repo.delete_all(EventLog)

    {:ok, []}
  end

  describe "call" do
    test "always returns paginated results" do
      response_keys = ListEventLogs.call()
        |> Map.from_struct()
        |> Map.keys()

      pagination_keys = [
        :entries,
        :page_number,
        :page_size,
        :total_entries,
        :total_pages
      ]

      assert response_keys == pagination_keys
    end

    test "returns empty list when no event logs exist" do
      assert ListEventLogs.call().entries == []
    end

    test "returns existing event logs" do
      event_log = insert(:event_log)

      event_logs = ListEventLogs.call()

      assert hd(event_logs.entries).id == event_log.id
    end

    test "returns a list of event logs" do
      count = 3
      insert_list(count, :event_log)

      event_logs = ListEventLogs.call()

      assert length(event_logs.entries) == count
    end
  end
end
