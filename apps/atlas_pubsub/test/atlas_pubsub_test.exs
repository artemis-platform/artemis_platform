defmodule AtlasPubSubTest do
  use ExUnit.Case

  describe "subscribe/1" do
    test "subscribes the current process to the give topic" do
      message = "test!"

      :ok = AtlasPubSub.subscribe("test")
      :ok = AtlasPubSub.direct_broadcast!("test", {:message, message})

      assert_receive {:message, ^message}
    end
  end

  describe "unsubscribe/1" do
    test "unsubscribes the current process from the give topic" do
      message = "test!"

      :ok = AtlasPubSub.subscribe("test")
      :ok = AtlasPubSub.unsubscribe("test")
      :ok = AtlasPubSub.direct_broadcast!("test", {:message, message})

      refute_receive {:message, ^message}
    end
  end
end
