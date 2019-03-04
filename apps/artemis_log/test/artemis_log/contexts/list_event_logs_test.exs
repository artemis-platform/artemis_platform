defmodule ArtemisLog.ListEventLogsTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.ListEventLogs
  alias ArtemisLog.Repo
  alias ArtemisLog.EventLog

  setup do
    Repo.delete_all(EventLog)

    {:ok, []}
  end

  describe "call" do
    test "always returns paginated results" do
      response_keys = ListEventLogs.call(Mock.system_user())
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
      assert ListEventLogs.call(Mock.system_user()).entries == []
    end

    test "returns existing event logs" do
      event_log = insert(:event_log)

      event_logs = ListEventLogs.call(Mock.system_user())

      assert hd(event_logs.entries).id == event_log.id
    end

    test "returns a list of event logs" do
      count = 3
      insert_list(count, :event_log)

      event_logs = ListEventLogs.call(Mock.system_user())

      assert length(event_logs.entries) == count
    end
  end

  describe "call - params" do
    setup do
      event_log = insert(:event_log)

      {:ok, event_log: event_log}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys = ListEventLogs.call(params, Mock.system_user())
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

    test "query - search" do
      insert(:event_log, user_name: "John Smith", action: "create-user")
      insert(:event_log, user_name: "Jill Smith", action: "create-role")
      insert(:event_log, user_name: "John Doe", action: "update-user")

      user = Mock.system_user()
      %{entries: event_logs} = ListEventLogs.call(user)

      assert length(event_logs) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      %{entries: event_logs} = ListEventLogs.call(params, user)

      assert length(event_logs) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "create-"
      }

      %{entries: event_logs} = ListEventLogs.call(params, user)

      assert length(event_logs) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith"
      }

      %{entries: event_logs} = ListEventLogs.call(params, user)

      assert length(event_logs) == 0
    end
  end
end
