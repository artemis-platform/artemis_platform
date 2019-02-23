defmodule AtlasWeb.UserPageTest do
  use AtlasWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Atlas.Factories
  import AtlasWeb.BrowserHelpers
  import AtlasWeb.Router.Helpers

  @moduletag :browser
  @url user_url(AtlasWeb.Endpoint, :index)

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
      assert page_title() == "Atlas"
      assert visible?("Listing Users")
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
      submit_form()

      assert visible?("can't be blank")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_inputs(%{
        user_email: "email@test.com",
        user_name: "Test Name"
      })

      submit_form()

      assert visible?("Test Name")
      assert visible?("email@test.com")
    end
  end

  describe "show" do
    setup do
      user = insert(:user)

      browser_sign_in()
      navigate_to(@url)

      {:ok, user: user}
    end

    test "record details", %{user: user} do
      click_link(user.name)

      assert visible?(user.name)
      assert visible?(user.email)
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

      fill_inputs(%{
        user_email: "updated@test.com",
        user_name: "Updated Name"
      })

      submit_form()

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
end
