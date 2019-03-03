defmodule ArtemisApi.Plug.HealthCheck do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts), do: send_resp(conn, 200, "")
end
