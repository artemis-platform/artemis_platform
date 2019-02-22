defmodule AtlasWeb.BrowserHelpers do
  use Hound.Helpers

  import AtlasWeb.Router.Helpers

  def browser_sign_in() do
    navigate_to(session_url(AtlasWeb.Endpoint, :new))
    click_link("Local Provider")
  end

  # Actions

  def click_button(text), do: click({:xpath, "//button[text()='#{text}']"})

  def click_link(text), do: click({:link_text, text})

  def fill_inputs(params) do
    Enum.each(params, fn ({key, value}) ->
      fill_input(key, value)
    end)
  end

  def fill_input(key, value), do: fill_field({:id, key}, value)

  def submit_form(), do: click({:css, "button[type='submit']"})

  # Assertions

  def redirected_to_sign_in_page?() do
    current_path() == session_path(AtlasWeb.Endpoint, :new)
  end

  def visible?(value) when is_bitstring(value) do
    value
    |> Regex.compile!()
    |> visible_in_page?
  end
  def visible?(value) when is_integer(value), do: visible?(Integer.to_string(value))
  def visible?(value), do: visible_in_page?(value)
end
