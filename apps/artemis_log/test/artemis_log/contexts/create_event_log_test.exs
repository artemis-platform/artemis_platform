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

      assert_raise FunctionClauseError, fn () ->
        CreateEventLog.call("event", payload)
      end
    end

    test "returns error when event is nil", %{user: user} do
      {:error, changeset} = CreateEventLog.call(nil, %{data: nil, user: user})

      assert errors_on(changeset).action == ["can't be blank"]
    end

    test "returns error when user params are empty" do
      user = %{
        id: nil,
        name: nil
      }

      {:error, changeset} = CreateEventLog.call(nil, %{data: nil, user: user})

      assert errors_on(changeset).user_id == ["can't be blank"]
      assert errors_on(changeset).user_name == ["can't be blank"]
    end

    test "creates a record when passed valid params", %{user: user} do
      event = "test:event"
      data = %{
        custom: :meta_data,
        multiple: %{
          levels: %{
            deep: true
          }
        }
      }

      params = %{
        data: data,
        user: user
      }

      {:ok, event_log} = CreateEventLog.call(event, params)

      assert event_log.action == event
      assert event_log.meta == data
      assert event_log.user_id == user.id
      assert event_log.user_name == user.name
    end
  end
end
