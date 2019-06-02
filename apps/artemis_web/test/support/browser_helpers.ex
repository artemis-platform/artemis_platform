defmodule ArtemisWeb.BrowserHelpers do
  use Hound.Helpers

  import ArtemisWeb.Router.Helpers

  def browser_sign_in() do
    navigate_to(auth_url(ArtemisWeb.Endpoint, :new))
    click_link("Log in as System User")
  end

  # Actions

  def click_button(text), do: click({:xpath, "//button[text()='#{text}']"})

  def click_link(text), do: click({:link_text, text})

  def fill_inputs(identifier, params) do
    form = find_element(:css, identifier)

    Enum.each(params, fn {name, value} ->
      form
      |> find_within_element(:name, name)
      |> fill_input(value)
    end)
  end

  def fill_input(element, value), do: fill_field(element, value)

  def fill_enhanced_select(element, value) when is_bitstring(value), do: fill_enhanced_select(element, [value])

  def fill_enhanced_select(element, values) when is_list(values) do
    click({:css, "#{element} .select2-container"})

    Enum.map(values, fn value ->
      fill_field({:css, "#{element} .select2-search__field"}, value)
      send_keys(:enter)
    end)
  end

  def submit_form(identifier), do: click({:css, "#{identifier} button[type='submit']"})

  def submit_search(identifier), do: submit_element({:css, identifier})

  # Assertions

  def redirected_to_sign_in_page?() do
    current_path() == auth_path(ArtemisWeb.Endpoint, :new)
  end

  def visible?(value) when is_bitstring(value) do
    value
    |> Regex.compile!()
    |> visible_in_page?
  end

  def visible?(value) when is_integer(value), do: visible?(Integer.to_string(value))
  def visible?(value), do: visible_in_page?(value)

  # Helpers

  def try_for(func, interval \\ 100, maximum \\ 1000, total \\ 0) do
    case func.() do
      true -> true
      false -> wait_for(func, interval, maximum, total)
    end
  end

  def wait_for(func, interval \\ 100, maximum \\ 1000, total \\ 0) do
    :timer.sleep(interval)

    case func.() do
      true ->
        true

      false ->
        case total < interval do
          true -> wait_for(func, interval, maximum, total + interval)
          false -> false
        end
    end
  end

  # Debug

  def print_page_source() do
    options = [
      limit: :infinity,
      printable_limit: :infinity
    ]

    IO.inspect(page_source(), options)
  end
end
