defmodule Mix.TaskHelpers.Progress do
  @moduledoc """
  Progress Bars and Status Spinners

  ## Examples

      progress_bar(97, 100)

  ## Elixir Libraries

  [ProgressBar](https://github.com/henrik/progress_bar)
  [ElixirCliSpinners](https://github.com/blackode/elixir_cli_spinners)
  """

  def progress_bar(current, total, format \\ []) do
    default_format = [
      bar_color: [IO.ANSI.white(), IO.ANSI.green_background()],
      blank_color: IO.ANSI.blue_background(),
      # default: "="
      bar: "…",
      # default: " "
      blank: " "
      # left: "(",  # default: "|"
      # right: ")", # default: "|"
    ]

    merged_format = Keyword.merge(default_format, format)

    ProgressBar.render(current, total, merged_format)
  end

  @doc """
  Shows a spinner animation while a callback function is executing

  ## Examples

      spinner(fn ->
        :timer.sleep(3_000)
      end)

  """
  def spinner(callback, format \\ []) do
    default_format = [
      # done: :remove,
      done: [IO.ANSI.green(), "✓", IO.ANSI.reset(), " Loaded"],
      frames: :braille,
      text: "Loading…",
      spinner_color: IO.ANSI.magenta()
    ]

    merged_format = Keyword.merge(default_format, format)

    ProgressBar.render_spinner(merged_format, callback)
  end
end
