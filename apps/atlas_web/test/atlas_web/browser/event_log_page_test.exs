defmodule AtlasWeb.EventLogPageTest do
  use AtlasWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import AtlasLog.Factories
  import AtlasWeb.BrowserHelpers
  import AtlasWeb.Router.Helpers

  @moduletag :browser
  @url event_log_url(AtlasWeb.Endpoint, :index)

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
      assert visible?("Listing Event Logs")
    end
  end

  describe "show" do
    setup do
      event_log = insert(:event_log)
      url = event_log_url(AtlasWeb.Endpoint, :show, event_log)

      browser_sign_in()
      navigate_to(url)

      {:ok, event_log: event_log}
    end

    test "record details", %{event_log: event_log} do
      assert visible?(event_log.action)
      assert visible?(event_log.user_id)
      assert visible?(event_log.user_name)
    end
  end
end
