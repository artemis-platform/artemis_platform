defmodule ArtemisApi.UserAccess do
  @moduledoc """
  A thin wrapper around `Artemis.UserAccess`.

  Adds functions to validate request user.

  Sources Supported:
  - `context` from Abinsthe GraphQL
  - `socket` from Phoenix Socket
  """

  import Artemis.UserAccess

  alias Artemis.Feature

  def require_feature(_request, feature, action) do
    case Feature.active?(feature) do
      true -> action.()
      false -> {:error, "Unauthorized Feature"}
    end
  end

  def require_permission(request, permissions, action) do
    with {:ok, user} <- fetch_user(request),
         true <- has_any?(user, permissions) do
      action.()
    else
      _ -> {:error, "Unauthorized User"}
    end
  end

  # Helpers

  def get_user(%{assigns: %{user: user}}), do: user
  def get_user(%{context: %{user: user}}), do: user
  def get_user(_), do: nil

  defp fetch_user(%{assigns: %{user: user}}), do: {:ok, user}
  defp fetch_user(%{context: %{user: user}}), do: {:ok, user}
  defp fetch_user(_), do: {:error, "User not found"}
end
