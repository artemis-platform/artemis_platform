defmodule ArtemisWeb.ViewHelper.Cache do
  use Phoenix.HTML

  alias ArtemisWeb.ViewHelper.Print

  @doc """
  Render cache meta data
  """
  def render_cache_meta_data(cache) do
    timestamp = get_cache_timestamp(cache)

    content_tag(:div, timestamp, class: "cache-meta-data")
  end

  defp get_cache_timestamp(%{inserted_at: nil}), do: "Not cached"

  defp get_cache_timestamp(%{inserted_at: time}) do
    "Cached #{Print.render_relative_time(time)} on #{Print.render_date_time_with_seconds(time)}"
  end
end
