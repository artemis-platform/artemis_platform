defmodule ArtemisWeb.EventLogPageTest do
  use ArtemisWeb.ConnCase
  use ExUnit.Case
  use Hound.Helpers

  import ArtemisLog.Factories
  import ArtemisWeb.BrowserHelpers
  import ArtemisWeb.Router.Helpers

  @moduletag :browser
  @url event_log_url(ArtemisWeb.Endpoint, :index)

  hound_session()

  describe "authentication" do
    test "requires authentication" do
      navigate_to(@url)

      assert redirected_to_sign_in_page?()
    end
  end

  describe "index" do
    setup do
      event_log = insert(:event_log)

      browser_sign_in()
      navigate_to(@url)

      {:ok, event_log: event_log}
    end

    test "list of records" do
      assert page_title() == "Artemis"
      assert visible?("Event Logs")
    end

    test "search", %{event_log: event_log} do
      fill_inputs(".search-resource", %{
        query: event_log.action
      })

      submit_search(".search-resource")

      assert visible?(event_log.action)
    end
  end

  describe "show" do
    setup do
      event_log = insert(:event_log)
      url = event_log_url(ArtemisWeb.Endpoint, :show, event_log)

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
