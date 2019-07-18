defmodule Artemis.Helpers.Feature do
  alias Artemis.Feature
  alias Artemis.GetSystemUser
  alias Artemis.ListFeatures

  @doc """
  Returns active value for a given feature.
  """
  def active?(%Feature{} = feature), do: feature.active

  def active?(slug) when is_bitstring(slug) do
    system_user = GetSystemUser.call_with_cache().data
    cache = ListFeatures.call_with_cache(system_user)
    record = Enum.find(cache.data, &(&1.slug == slug))

    case record do
      nil -> false
      _ -> record.active
    end
  end
end
