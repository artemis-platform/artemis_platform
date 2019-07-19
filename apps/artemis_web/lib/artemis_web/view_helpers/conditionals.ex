defmodule ArtemisWeb.ViewHelper.Conditionals do
  alias Artemis.Helpers.Feature

  @moduledoc """
  Functions for conditional rendering
  """

  def active_feature?(slug), do: Feature.active?(slug)
end
