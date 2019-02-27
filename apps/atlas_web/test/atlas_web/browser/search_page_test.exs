defmodule AtlasWeb.SearchPageTest do
  use AtlasWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import AtlasWeb.BrowserHelpers
  import AtlasWeb.Router.Helpers

  @moduletag :browser
  @url search_url(AtlasWeb.Endpoint, :index)

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

    test "search" do
      user = Mock.system_user()

      fill_inputs("#primary-header .search", %{
        query: user.email
      })

      submit_form("#primary-header .search")

      assert visible?("Search Summary")
      assert visible?("Search Results")
      assert visible?("Users")
      assert visible?(user.name)
    end
  end
end
