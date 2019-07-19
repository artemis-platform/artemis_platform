defmodule Artemis.GetSystemUserTest do
  use Artemis.DataCase

  alias Artemis.GetSystemUser
  alias Artemis.User

  setup do
    system_user = Mock.system_user()

    {:ok, system_user: system_user}
  end

  describe "call!" do
    test "raises an exception when system user not found", %{system_user: system_user} do
      original_email = system_user.email
      temporary_email = "temporary@email.com"

      # Simulate deleting by moving system user record

      moved =
        system_user
        |> User.changeset(%{email: temporary_email})
        |> Repo.update!()

      assert_raise Ecto.NoResultsError, fn ->
        GetSystemUser.call!() == nil
      end

      # Return system user record

      moved
      |> User.changeset(%{email: original_email})
      |> Repo.update!()

      assert GetSystemUser.call!() != nil
    end

    test "returns system user", %{system_user: system_user} do
      assert GetSystemUser.call!().id == system_user.id
    end
  end

  describe "call" do
    test "returns an error when system user not found", %{system_user: system_user} do
      original_email = system_user.email
      temporary_email = "temporary@email.com"

      # Simulate deleting by moving system user record

      moved =
        system_user
        |> User.changeset(%{email: temporary_email})
        |> Repo.update!()

      assert GetSystemUser.call() == nil

      # Return system user record

      moved
      |> User.changeset(%{email: original_email})
      |> Repo.update!()

      assert GetSystemUser.call() != nil
    end

    test "returns system user without any arguments", %{system_user: system_user} do
      assert GetSystemUser.call().id == system_user.id
    end
  end

  describe "call - options" do
    test "preload" do
      result = GetSystemUser.call()

      assert !is_list(result.auth_providers)
      assert result.auth_providers.__struct__ == Ecto.Association.NotLoaded

      options = [
        preload: [:auth_providers]
      ]

      result = GetSystemUser.call(options)

      assert is_list(result.auth_providers)
    end
  end

  describe "cache" do
    setup do
      GetSystemUser.reset_cache()
      GetSystemUser.call_with_cache()

      {:ok, []}
    end

    test "defines a custom cache key" do
      assert GetSystemUser.call_with_cache().key == [:system_user, options: []]

      options = [
        preload: [:auth_providers]
      ]

      assert GetSystemUser.call_with_cache(options).key == [:system_user, options: [options]]
    end

    test "defines custom cache options" do
      GetSystemUser.call_with_cache()

      expiration = :timer.minutes(60)
      limit = 5

      cachex_options = Artemis.CacheInstance.get_cachex_options(GetSystemUser)

      assert cachex_options[:expiration] == {:expiration, expiration, 5000, true}
      assert cachex_options[:limit] == limit
    end

    test "returns a cached result", %{system_user: record} do
      initial_call = GetSystemUser.call_with_cache()

      assert initial_call.__struct__ == Artemis.CacheInstance.CacheEntry
      assert initial_call.data.id == record.id
      assert initial_call.data.auth_providers.__struct__ == Ecto.Association.NotLoaded
      assert initial_call.inserted_at != nil
      assert initial_call.key != nil

      cache_hit = GetSystemUser.call_with_cache()

      assert cache_hit.data.id == record.id
      assert cache_hit.data.auth_providers.__struct__ == Ecto.Association.NotLoaded
      assert cache_hit.inserted_at != nil
      assert cache_hit.inserted_at == initial_call.inserted_at
      assert cache_hit.key != nil

      options = [
        preload: [:auth_providers]
      ]

      different_key = GetSystemUser.call_with_cache(options)

      assert different_key.data.id == record.id
      assert different_key.data.auth_providers == []
      assert different_key.inserted_at != nil
      assert different_key.key != nil
    end
  end
end
