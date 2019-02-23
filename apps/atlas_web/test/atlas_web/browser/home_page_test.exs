defmodule AtlasWeb.HomePageTest do
  use AtlasWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import AtlasWeb.BrowserHelpers
  import AtlasWeb.Router.Helpers

  @moduletag :browser
  @url home_url(AtlasWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "when unauthenticated show log in link" do
      navigate_to(@url)

      assert visible?("Log In")
    end

    test "when authenticated do not show log in link" do
      browser_sign_in()
      navigate_to(@url)

      assert not visible?("Log In")
    end
  end

  describe "index" do
    setup do
      browser_sign_in()
      navigate_to(@url)

      {:ok, []}
    end

    test "page content" do
      assert page_title() == "Atlas"
      assert visible?("Atlas Dashboard")
    end
  end
end
