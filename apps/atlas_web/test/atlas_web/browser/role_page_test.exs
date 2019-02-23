defmodule AtlasWeb.RolePageTest do
  use AtlasWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Atlas.Factories
  import AtlasWeb.BrowserHelpers
  import AtlasWeb.Router.Helpers

  @moduletag :browser
  @url role_url(AtlasWeb.Endpoint, :index)

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
      assert visible?("Listing Roles")
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
        role_name: "Test Name",
        role_slug: "test-slug"
      })

      submit_form()

      assert visible?("Test Name")
      assert visible?("test-slug")
    end
  end

  describe "show" do
    setup do
      role = insert(:role)

      browser_sign_in()
      navigate_to(@url)

      {:ok, role: role}
    end

    test "record details", %{role: role} do
      click_link(role.name)

      assert visible?(role.name)
      assert visible?(role.slug)
    end
  end

  describe "edit / update" do
    setup do
      role = insert(:role)

      browser_sign_in()
      navigate_to(@url)

      {:ok, role: role}
    end

    test "successfully updates record", %{role: role} do
      click_link(role.name)
      click_link("Edit")

      fill_inputs(%{
        role_name: "Updated Name",
        role_slug: "updated-slug"
      })

      submit_form()

      assert visible?("Updated Name")
      assert visible?("updated-slug")
    end
  end

  describe "delete" do
    setup do
      role = insert(:role)

      browser_sign_in()
      navigate_to(@url)

      {:ok, role: role}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{role: role} do
    #   click_link(role.name)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == @url
    #   assert not visible?(role.name)
    # end
  end
end
