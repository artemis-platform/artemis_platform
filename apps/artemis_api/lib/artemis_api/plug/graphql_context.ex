defmodule ArtemisApi.Plug.GraphQLContext do
  @moduledoc """
  Reads the `plug_auth` key set in an earlier plug.
  Sets the Absinthe current user context under the `absinthe` key.
  """

  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case Map.get(conn.private, :guardian_default_resource, nil) do
      nil -> conn
      user -> put_private(conn, :absinthe, %{context: %{user: user}})
    end
  end
end
