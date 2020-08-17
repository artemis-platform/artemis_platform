defmodule Mix.TaskHelpers.Colors do
  @moduledoc """
  ANSI compatible colors

  ## Elixir Libraries

  [IO.Ansi](https://hexdocs.pm/elixir/IO.ANSI.html)
  """

  def blue(value) do
    [IO.ANSI.blue(), value, IO.ANSI.reset()]
  end

  def cyan(value) do
    [IO.ANSI.cyan(), value, IO.ANSI.reset()]
  end

  def gray(value) do
    [IO.ANSI.light_black(), value, IO.ANSI.reset()]
  end

  def green(value) do
    [IO.ANSI.green(), value, IO.ANSI.reset()]
  end

  def magenta(value) do
    [IO.ANSI.magenta(), value, IO.ANSI.reset()]
  end

  def red(value) do
    [IO.ANSI.red(), value, IO.ANSI.reset()]
  end

  def yellow(value) do
    [IO.ANSI.yellow(), value, IO.ANSI.reset()]
  end
end
