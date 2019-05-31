defmodule ArtemisLog.ListHttpRequestLogsTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.ListHttpRequestLogs
  alias ArtemisLog.HttpRequestLog
  alias ArtemisLog.Repo

  setup do
    Repo.delete_all(HttpRequestLog)

    {:ok, []}
  end

  describe "call" do
    test "always returns paginated results" do
      response_keys =
        ListHttpRequestLogs.call(Mock.system_user())
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

    test "returns empty list when no request logs exist" do
      assert ListHttpRequestLogs.call(Mock.system_user()).entries == []
    end

    test "returns existing request logs" do
      request_log = insert(:http_request_log)

      request_logs = ListHttpRequestLogs.call(Mock.system_user())

      assert hd(request_logs.entries).id == request_log.id
    end

    test "returns a list of request logs" do
      count = 3
      insert_list(count, :http_request_log)

      request_logs = ListHttpRequestLogs.call(Mock.system_user())

      assert length(request_logs.entries) == count
    end
  end

  describe "call - params" do
    setup do
      request_log = insert(:http_request_log)

      {:ok, request_log: request_log}
    end

    test "order" do
      insert_list(3, :http_request_log)

      params = %{order: "endpoint"}
      ascending = ListHttpRequestLogs.call(params, Mock.system_user())

      params = %{order: "-endpoint"}
      descending = ListHttpRequestLogs.call(params, Mock.system_user())

      assert ascending.entries == Enum.reverse(descending.entries)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListHttpRequestLogs.call(params, Mock.system_user())
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
  end
end
