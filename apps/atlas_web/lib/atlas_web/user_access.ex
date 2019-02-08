defmodule AtlasWeb.UserAccess do
  @moduledoc """
  A thin wrapper around `Atlas.UserAccess`.

  Adds the ability to pull the current user from connection context.
  """
  import AtlasWeb.Guardian.Helpers, only: [current_user: 1]

  alias Plug.Conn

  def has?(%Conn{} = conn, permission), do: Atlas.UserAccess.has?(current_user(conn), permission)
  def has?(user, permission), do: Atlas.UserAccess.has?(user, permission)

  def has_any?(%Conn{} = conn, permission), do: Atlas.UserAccess.has_any?(current_user(conn), permission)
  def has_any?(user, permission), do: Atlas.UserAccess.has_any?(user, permission)

  def has_all?(%Conn{} = conn, permission), do: Atlas.UserAccess.has_all?(current_user(conn), permission)
  def has_all?(user, permission), do: Atlas.UserAccess.has_all?(user, permission)
end
