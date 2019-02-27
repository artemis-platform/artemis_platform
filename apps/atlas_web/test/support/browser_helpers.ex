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

  def fill_inputs(identifier, params) do
    form = find_element(:css, identifier)

    Enum.each(params, fn ({name, value}) ->
      form
      |> find_within_element(:name, name)
      |> fill_input(value)
    end)
  end

  def fill_input(element, value), do: fill_field(element, value)

  def submit_form(identifier), do: click({:css, "#{identifier} button[type='submit']"})

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
