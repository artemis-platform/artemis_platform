defmodule ArtemisWeb.FeaturePageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import Artemis.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser
  @url feature_url(ArtemisWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      navigate_to(@url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      feature = insert(:feature)

      browser_sign_in()
      navigate_to(@url)

      {:ok, feature: feature}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Features")
    end

    test "search", %{feature: feature} do
      fill_inputs(".search-resource", %{
        query: feature.slug
      })

      submit_search(".search-resource")

      assert visible?(feature.slug)
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
      submit_form("#feature-form")

      assert visible?("can't be blank")
    end

    test "successfully creates a new record" do
      click_link("New")

      fill_inputs("#feature-form", %{
        "feature[name]": "Test Name",
        "feature[slug]": "test-slug"
      })

      submit_form("#feature-form")

      assert visible?("Test Name")
      assert visible?("test-slug")
    end
  end

  describe "show" do
    setup do
      feature = insert(:feature)

      Artemis.ListFeatures.reset_cache()

      browser_sign_in()
      navigate_to(@url)

      {:ok, feature: feature}
    end

    test "record details", %{feature: feature} do
      click_link(feature.slug)

      assert visible?(feature.name)
      assert visible?(feature.slug)
    end
  end

  describe "edit / update" do
    setup do
      feature = insert(:feature)

      Artemis.ListFeatures.reset_cache()

      browser_sign_in()
      navigate_to(@url)

      {:ok, feature: feature}
    end

    test "successfully updates record", %{feature: feature} do
      click_link(feature.slug)
      click_link("Edit")

      fill_inputs("#feature-form", %{
        "feature[name]": "Updated Name",
        "feature[slug]": "updated-slug"
      })

      submit_form("#feature-form")

      assert visible?("Updated Name")
      assert visible?("updated-slug")
    end
  end

  describe "delete" do
    setup do
      feature = insert(:feature)

      browser_sign_in()
      navigate_to(@url)

      {:ok, feature: feature}
    end

    @tag :uses_browser_alert_box
    # test "deletes record and redirects to index", %{feature: feature} do
    #   click_link(feature.slug)
    #   click_button("Delete")
    #   accept_dialog()

    #   assert current_url() == @url
    #   assert not visible?(feature.slug)
    # end
  end
end
