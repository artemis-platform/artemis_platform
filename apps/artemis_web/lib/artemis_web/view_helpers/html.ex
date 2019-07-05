defmodule ArtemisWeb.ViewHelper.HTML do
  use Phoenix.HTML

  @doc """
  Generates an action tag.

  Type of tag is determined by the `method`:

    GET: Anchor
    POST / PUT / PATCH / DELETE: Button (with CSRF token)

  Unless specified, the `method` value defaults to `GET`.

  Custom options:

    :color <String>
    :size <String>

  All other options are passed directly to the `Phoenix.HTML` function.
  """
  def action(label, options \\ []) do
    color = Keyword.get(options, :color, "basic")
    size = Keyword.get(options, :size, "small")
    method = Keyword.get(options, :method, "get")

    tag_options =
      options
      |> Enum.into(%{})
      |> Map.put(:class, "button ui #{size} #{color}")
      |> Enum.into([])

    if method == "get" do
      link(label, tag_options)
    else
      button(label, tag_options)
    end
  end
end
