defmodule ArtemisLog.DeleteAllHttpRequestLogsOlderThanTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.DeleteAllHttpRequestLogsOlderThan

  setup do
    http_request_log = insert(:http_request_log)

    {:ok, http_request_log: http_request_log}
  end

  describe "call!" do
    test "raises an exception when given invalid arguments" do
      invalid_timestamp = nil

      assert_raise ArtemisLog.Context.Error, fn ->
        DeleteAllHttpRequestLogsOlderThan.call!(invalid_timestamp, Mock.system_user())
      end
    end

    test "returns successfully when given a valid timestamp" do
      timestamp = DateTime.utc_now()

      %{total: _} = DeleteAllHttpRequestLogsOlderThan.call!(timestamp, Mock.system_user())
    end
  end

  describe "call" do
    test "raises an exception when given invalid arguments" do
      invalid_timestamp = nil

      result = DeleteAllHttpRequestLogsOlderThan.call(invalid_timestamp, Mock.system_user())

      assert result == {:error, "Invalid timestamp"}
    end

    test "returns successfully when given a valid timestamp" do
      timestamp = DateTime.utc_now()

      {:ok, _} = DeleteAllHttpRequestLogsOlderThan.call(timestamp, Mock.system_user())
    end

    test "successfully deletes items before specified timestamp" do
      now = Timex.now()
      one_week_ago = Timex.subtract(now, Timex.Duration.from_days(7))
      two_weeks_ago = Timex.subtract(now, Timex.Duration.from_days(14))
      three_weeks_ago = Timex.subtract(now, Timex.Duration.from_days(21))

      insert(:http_request_log, inserted_at: now)
      insert(:http_request_log, inserted_at: one_week_ago)
      insert(:http_request_log, inserted_at: two_weeks_ago)
      insert(:http_request_log, inserted_at: three_weeks_ago)

      {:ok, result} = DeleteAllHttpRequestLogsOlderThan.call(one_week_ago, Mock.system_user())

      assert result.timestamp == one_week_ago
      assert result.total == 2
    end

    test "successfully returns 0 total when none match" do
      now = Timex.now()
      one_week_ago = Timex.subtract(now, Timex.Duration.from_days(7))
      two_weeks_ago = Timex.subtract(now, Timex.Duration.from_days(14))

      insert(:http_request_log, inserted_at: now)
      insert(:http_request_log, inserted_at: one_week_ago)

      {:ok, result} = DeleteAllHttpRequestLogsOlderThan.call(two_weeks_ago, Mock.system_user())

      assert result.timestamp == two_weeks_ago
      assert result.total == 0
    end
  end

  @tag :pending
  describe "broadcasts" do
    test "publishes event and record" do
      now = Timex.now()
      one_week_ago = Timex.subtract(now, Timex.Duration.from_days(7))
      two_weeks_ago = Timex.subtract(now, Timex.Duration.from_days(14))
      three_weeks_ago = Timex.subtract(now, Timex.Duration.from_days(21))

      insert(:http_request_log, inserted_at: now)
      insert(:http_request_log, inserted_at: one_week_ago)
      insert(:http_request_log, inserted_at: two_weeks_ago)
      insert(:http_request_log, inserted_at: three_weeks_ago)

      {:ok, result} = DeleteAllHttpRequestLogsOlderThan.call(one_week_ago, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "http-request-logs:deleted",
        payload: %{
          data: ^result
        }
      }
    end
  end
end
