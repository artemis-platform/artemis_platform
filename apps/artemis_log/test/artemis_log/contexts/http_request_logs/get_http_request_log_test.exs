defmodule ArtemisLog.GetHttpRequestLogTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.GetHttpRequestLog

  setup do
    user = Mock.system_user()
    request_log = insert(:http_request_log, user_id: user.id, user_name: user.name)

    {:ok, request_log: request_log}
  end

  describe "call" do
    test "returns nil request log not found" do
      invalid_id = 50_000_000

      assert GetHttpRequestLog.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds request log by id", %{request_log: request_log} do
      assert GetHttpRequestLog.call(request_log.id, Mock.system_user()).id == request_log.id
    end

    test "finds request log keyword list", %{request_log: request_log} do
      values = [user_id: request_log.user_id, user_name: request_log.user_name]
      user = Mock.system_user()

      assert GetHttpRequestLog.call(values, user).id == request_log.id
    end
  end

  describe "call!" do
    test "raises an exception request log not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetHttpRequestLog.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds request log by id", %{request_log: request_log} do
      assert GetHttpRequestLog.call!(request_log.id, Mock.system_user()).id == request_log.id
    end
  end
end
