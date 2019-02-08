defmodule AtlasApi.HealthCheckTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts AtlasApi.Router.init([])

  describe "healthcheck" do
    test "returns 200 when sent valid request" do
      # Create a test conn
      conn = conn(:get, "/health_check")

      # Call the plug
      conn = AtlasApi.Router.call(conn, @opts)

      # Assert
      assert conn.state == :sent
      assert conn.status == 200
      assert conn.resp_body == ""
    end
  end
end
