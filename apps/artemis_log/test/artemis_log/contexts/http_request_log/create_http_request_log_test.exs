defmodule ArtemisLog.CreateHttpRequestLogTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.CreateHttpRequestLog

  setup do
    user = %{
      id: 1,
      name: "Test User"
    }

    {:ok, user: user}
  end

  describe "call" do
    test "raises an exception when missing required params" do
      payload = %{}

      assert_raise FunctionClauseError, fn ->
        CreateHttpRequestLog.call(payload)
      end
    end

    test "returns error when missing required user values" do
      params = %{
        data: params_for(:http_request_log),
        user: nil
      }

      {:error, changeset} = CreateHttpRequestLog.call(params)

      assert errors_on(changeset).user_id == ["can't be blank"]
      assert errors_on(changeset).user_name == ["can't be blank"]
    end

    test "returns error when missing required data values", %{user: user} do
      params = %{
        data: %{},
        user: user
      }

      {:error, changeset} = CreateHttpRequestLog.call(params)

      assert errors_on(changeset).endpoint == ["can't be blank"]
      assert errors_on(changeset).node == ["can't be blank"]
      assert errors_on(changeset).path == ["can't be blank"]
    end

    test "returns error when user params are empty" do
      params = %{
        data: params_for(:http_request_log),
        user: %{id: nil, name: nil}
      }

      {:error, changeset} = CreateHttpRequestLog.call(params)

      assert errors_on(changeset).user_id == ["can't be blank"]
      assert errors_on(changeset).user_name == ["can't be blank"]
    end

    test "creates a record when passed valid params", %{user: user} do
      params = %{
        data: params_for(:http_request_log),
        user: user
      }

      {:ok, request_log} = CreateHttpRequestLog.call(params)

      assert request_log.endpoint == params.data.endpoint
      assert request_log.node == params.data.node
      assert request_log.path == params.data.path
      assert request_log.query_string == params.data.query_string
      assert request_log.user_id == params.user.id
      assert request_log.user_name == params.user.name
    end
  end
end
