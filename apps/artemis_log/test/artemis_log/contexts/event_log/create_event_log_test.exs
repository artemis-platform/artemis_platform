defmodule ArtemisLog.CreateEventLogTest do
  use ArtemisLog.DataCase

  alias ArtemisLog.CreateEventLog

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
        CreateEventLog.call("event", payload)
      end
    end

    test "returns error when event is nil", %{user: user} do
      {:error, changeset} = CreateEventLog.call(nil, %{data: nil, meta: nil, user: user})

      assert errors_on(changeset).action == ["can't be blank"]
    end

    test "returns error when user params are empty" do
      event = "test:event"

      user = %{
        id: nil,
        name: nil
      }

      {:error, changeset} = CreateEventLog.call(event, %{data: nil, meta: nil, user: user})

      assert errors_on(changeset).user_id == ["can't be blank"]
      assert errors_on(changeset).user_name == ["can't be blank"]
    end

    test "creates a record when passed valid params", %{user: user} do
      event = "test:event"

      data = %{
        custom: :data,
        multiple: %{
          levels: %{
            deep: true
          }
        }
      }

      meta = %{
        custom: :meta,
        multiple: %{
          levels: %{
            deep: true
          }
        }
      }

      params = %{
        data: data,
        meta: meta,
        user: user
      }

      {:ok, event_log} = CreateEventLog.call(event, params)

      assert event_log.action == event
      assert event_log.data == data
      assert event_log.meta == meta
      assert event_log.user_id == user.id
      assert event_log.user_name == user.name
    end

    test "creates a record when passed empty data and meta fields", %{user: user} do
      event = "test:event"

      {:ok, event_log} = CreateEventLog.call(event, %{data: nil, meta: nil, user: user})

      assert event_log.action == event
      assert event_log.data == nil
      assert event_log.meta == nil
      assert event_log.user_id == user.id
      assert event_log.user_name == user.name
    end
  end
end
