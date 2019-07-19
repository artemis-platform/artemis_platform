defmodule Artemis.CacheSupervisor do
  use DynamicSupervisor

  @moduledoc """
  Supervises all cache instances. Cache instances can be added dynamically when
  needed and added to the supervision tree.

  For more details on cache instances themselves, see `Artemis.CacheInstance`.
  """

  @child Artemis.CacheInstance

  def start_link(options \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: options[:name] || __MODULE__)
  end

  def start_child(options \\ []) do
    spec = {@child, options}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
