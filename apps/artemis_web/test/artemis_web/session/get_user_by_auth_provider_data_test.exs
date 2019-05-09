defmodule ArtemisWeb.GetUserByAuthProviderDataTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case

  import Artemis.Factories
  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.User
  alias ArtemisWeb.GetUserByAuthProviderData

  describe "auth providers" do
    test "returns an error when given data from an unsupported provider" do
      data = response_data(provider: :invalid)

      {:error, "Error auth provider not supported"} = GetUserByAuthProviderData.call(data)
    end

    test "returns successfully when given data from an enabled provider" do
      data = response_data(provider: :valid)
      options = [enable_all_providers: true]

      {:ok, _user} = GetUserByAuthProviderData.call(data, options)
    end
  end

  describe "data" do
    test "creates an auth provider and associated user when it does not already exist" do
      email = "create@email.com"
      uid = "create-uid"

      data = response_data(email: email, provider: :github, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      assert user.email == email
      assert user.last_log_in_at != nil

      assert hd(user.auth_providers).uid == uid
      assert hd(user.auth_providers).type == "github"

      assert hd(user.roles).slug == "default"
    end

    test "creates an auth provider and links to an existing user when it already exists" do
      email = "create@email.com"
      uid = "create-uid"

      user = insert(:user, email: email)

      # Existing User

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      assert user.email == email
      assert user.auth_providers == []
      assert user.roles == []

      # Create Auth Provider

      data = response_data(email: email, provider: :github, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      assert user.email == email
      assert user.last_log_in_at != nil

      assert hd(user.auth_providers).uid == uid
      assert hd(user.auth_providers).type == "github"

      assert user.roles == []
    end

    test "user record can have multiple associated auth providers" do
      email = "create@email.com"
      uid = "create-uid"
      provider = "github"

      data = response_data(email: email, provider: provider, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      assert user.email == email
      assert user.last_log_in_at != nil

      assert length(user.auth_providers) == 1
      assert hd(user.auth_providers).uid == uid
      assert hd(user.auth_providers).type == provider

      assert hd(user.roles).slug == "default"

      # Create second Auth Provider

      email = "create@email.com"
      uid = "create-uid"
      provider = "google"

      data = response_data(email: email, provider: provider, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      assert length(user.auth_providers) == 2
    end

    test "updates auth provider and associated user when it already exists" do
      original_email = "existing@email.com"
      uid = "update-uid"

      user = insert(:user, email: original_email, last_log_in_at: nil)
      insert(:auth_provider, type: "github", uid: uid, user: user)

      assert user.email == original_email
      assert user.last_log_in_at == nil

      # Update User and Auth Provider

      updated_email = "updated@email.com"

      data = response_data(email: updated_email, provider: :github, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user = User
        |> preload([:auth_providers, :roles])
        |> Repo.get(user.id)

      # Only updates specific attributes

      assert user.email == original_email
      assert user.last_log_in_at != nil

      assert hd(user.auth_providers).uid == uid
      assert hd(user.auth_providers).type == "github"

      # Does not update user associations

      assert user.roles == []
    end

    test "the auth provider email address can change" do
      original_email = "create@email.com"
      uid = "constant-uid"

      data = response_data(email: original_email, provider: :github, uid: uid)
      options = [enable_all_providers: true]

      {:ok, user} = GetUserByAuthProviderData.call(data, options)

      user_count = User
        |> Repo.all() 
        |> length()

      # Finds existing user by auth provider uid, not email

      updated_email = "updated@email.com"

      updated_data = response_data(email: updated_email, provider: :github, uid: uid)
      options = [enable_all_providers: true]

      {:ok, updated_user} = GetUserByAuthProviderData.call(updated_data, options)

      updated_user_count = User
        |> Repo.all() 
        |> length()

      assert user.email == original_email
      assert updated_user_count == user_count
      assert updated_user.id == user.id
    end
  end

  # Helpers

  def response_data(options \\ []) do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{
        expires: false,
        expires_at: nil,
        other: %{},
        refresh_token: nil,
        scopes: [""],
        secret: nil,
        token: "3dadf01df51ec40a0cd3986ecb36671fe5dcc45e",
        token_type: "Bearer"
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          token: %OAuth2.AccessToken{
            access_token: "3dadf01df51ec40a0cd3986ecb36671fe5dcc45e",
            expires_at: nil,
            other_params: %{"scope" => ""},
            refresh_token: nil,
            token_type: "Bearer"
          },
          user: %{
            "avatar_url" => "https://avatars1.githubusercontent.com/u/1?v=4",
            "bio" => nil,
            "blog" => nil,
            "company" => nil,
            "created_at" => "2018-01-01T00:00:00Z",
            "email" => options[:email] || "email@test.com",
            "events_url" => "https://api.github.com/users/test/events{/privacy}",
            "followers" => 1,
            "followers_url" => "https://api.github.com/users/test/followers",
            "following" => 1,
            "following_url" => "https://api.github.com/users/test/following{/other_user}",
            "gists_url" => "https://api.github.com/users/test/gists{/gist_id}",
            "gravatar_id" => "",
            "hireable" => nil,
            "html_url" => "https://github.com/test",
            "id" => 1,
            "location" => "New York",
            "login" => "test",
            "name" => options[:name] || "Test User",
            "node_id" => "NDQ6VXNlcjQ2MTE3Mg==",
            "organizations_url" => "https://api.github.com/users/test/orgs",
            "public_gists" => 1,
            "public_repos" => 1,
            "received_events_url" => "https://api.github.com/users/test/received_events",
            "repos_url" => "https://api.github.com/users/test/repos",
            "site_admin" => false,
            "starred_url" => "https://api.github.com/users/test/starred{/owner}{/repo}",
            "subscriptions_url" => "https://api.github.com/users/test/subscriptions",
            "type" => "User",
            "updated_at" => "2019-01-01T00:00:00Z",
            "url" => "https://api.github.com/users/test"
          }
        }
      },
      info: %Ueberauth.Auth.Info{
        description: nil,
        email: options[:email] || "email@test.com",
        first_name: options[:first_name] || "Test",
        image: "https://avatars1.githubusercontent.com/u/1?v=4",
        last_name: options[:last_name] || "User",
        location: "New York",
        name: options[:name] || "Test User",
        nickname: "test",
        phone: nil,
        urls: %{}
      },
      provider: options[:provider] || :github,
      strategy: Ueberauth.Strategy.Github,
      uid: options[:uid] || 1
    }
  end
end
