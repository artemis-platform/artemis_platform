defmodule ArtemisWeb.UserPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser
  @url user_url(ArtemisWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      navigate_to(@url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      browser_sign_in()
      navigate_to(@url)

      {:ok, []}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Users")
    end

    test "search" do
      user = Mock.system_user()

      fill_inputs(".search-resource", %{
        query: user.email
      })

      submit_search(".search-resource")

      assert visible?(user.name)
    end
  end

  describe "new / create" do
    setup do
      browser_sign_in()
      navigate_to(@url)

      {:ok, []}
    end

    test "submitting an empty form shows an error" do
      click_link("New")
      submit_form("#user-form")

      take_screenshot()

      assert visible?("can't be blank")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_inputs("#user-form", %{
        "user[email]": "email@test.com",
        "user[name]": "Test Name"
      })

      submit_form("#user-form")

      assert visible?("Test Name")
      assert visible?("email@test.com")
    end
  end

  describe "show" do
    setup do
      user =
        :user
        |> insert()
        |> with_permission("users:create")
        |> with_permission("users:list")

      browser_sign_in()
      navigate_to(@url)

      {:ok, user: user}
    end

    test "record details and associations", %{user: user} do
      click_link(user.name)

      assert visible?(user.name)
      assert visible?(user.email)

      assert visible?("Roles")
      assert visible?("Permissions")
      assert visible?("users:create")
      assert visible?("users:list")
    end
  end

  describe "edit / update" do
    setup do
      user = insert(:user)

      browser_sign_in()
      navigate_to(@url)

      {:ok, user: user}
    end

    test "successfully updates record", %{user: user} do
      click_link(user.name)
      click_link("Edit")

      fill_inputs("#user-form", %{
        "user[email]": "updated@test.com",
        "user[name]": "Updated Name"
      })

      submit_form("#user-form")

      assert visible?("Updated Name")
      assert visible?("updated@test.com")
    end
  end

  describe "delete" do
    setup do
      user = insert(:user)

      browser_sign_in()
      navigate_to(@url)

      {:ok, user: user}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{user: user} do
    #   click_link(user.name)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == @url
    #   assert not visible?(user.name)
    # end
  end

  describe "anonymize" do
    setup do
      user = insert(:user)

      browser_sign_in()
      navigate_to(@url)

      {:ok, user: user}
    end

    @tag :uses_browser_alert_box
    # test "anonymizes record and redirects to show", %{user: user} do
    #   click_link(user.name)
    #   click_button("Anonymize")
    #   accept_dialog()

    #   assert current_url() == "#{@url}/#{user.id}"
    #   assert not visible?(user.name)
    #   assert visible?("Anonymized User")
    # end
  end
end
