defmodule ArtemisWeb.PermissionPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser
  @url permission_url(ArtemisWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      navigate_to(@url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      permission = insert(:permission)

      browser_sign_in()
      navigate_to(@url)

      {:ok, permission: permission}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Permissions")
    end

    test "search", %{permission: permission} do
      fill_inputs(".search-resource", %{
        query: permission.name
      })

      submit_search(".search-resource")

      assert visible?(permission.name)
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
      submit_form("#permission-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_inputs("#permission-form", %{
        "permission[name]": "Test Name",
        "permission[slug]": "test-slug"
      })

      submit_form("#permission-form")

      assert visible?("Test Name")
      assert visible?("test-slug")
    end
  end

  describe "show" do
    setup do
      permission = insert(:permission)

      browser_sign_in()
      navigate_to(@url <> "?page_size=10000")

      {:ok, permission: permission}
    end

    test "record details", %{permission: permission} do
      click_link(permission.name)

      assert visible?(permission.name)
      assert visible?(permission.slug)
    end
  end

  describe "edit / update" do
    setup do
      permission = insert(:permission)

      browser_sign_in()
      navigate_to(@url <> "?page_size=10000")

      {:ok, permission: permission}
    end

    test "successfully updates record", %{permission: permission} do
      click_link(permission.name)
      click_link("Edit")

      fill_inputs("#permission-form", %{
        "permission[name]": "Updated Name",
        "permission[slug]": "updated-slug"
      })

      submit_form("#permission-form")

      assert visible?("Updated Name")
      assert visible?("updated-slug")
    end
  end

  describe "delete" do
    setup do
      permission = insert(:permission)

      browser_sign_in()
      navigate_to(@url)

      {:ok, permission: permission}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{permission: permission} do
    #   click_link(permission.slug)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == @url
    #   assert not visible?(permission.slug)
    # end
  end
end
