defmodule Artemis.Helpers.AppConfig do
  @doc """
  Fetch an app config value
  """
  def fetch!(app, module, key) do
    app
    |> Application.fetch_env!(module)
    |> Keyword.fetch!(key)
  end

  @doc """
  Fetch and parse an app config and return a boolean based on its value. Raises an
  exception if value is not set.
  """
  def enabled?(app, module, key) do
    app
    |> fetch!(module, key)
    |> enabled?()
  end

  def enabled?(config) when is_map(config) do
    config
    |> Map.fetch!(:enabled)
    |> enabled?()
  end

  def enabled?(config) when is_list(config) do
    config
    |> Keyword.fetch!(:enabled)
    |> enabled?()
  end

  def enabled?(value) when is_bitstring(value) do
    value
    |> String.downcase()
    |> String.equivalent?("true")
  end

  def enabled?(true), do: true
  def enabled?(_), do: false

  @doc """
  Verify if multiple entries are all enabled
  """
  def all_enabled?(entries) do
    Enum.all?(entries, fn arguments ->
      apply(Artemis.Helpers.AppConfig, :enabled?, arguments)
    end)
  end
end
