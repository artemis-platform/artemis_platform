defmodule Mix.TaskHelpers.Prompts do
  import Mix.TaskHelpers.Colors

  @moduledoc """
  Progress Bars and Status Spinners

  ## Elixir Libraries

  [ExPrompt](https://github.com/behind-design/ex_prompt)
  """

  @prompt gray("=>")
  @empty_responses ["", "\n", :eof]

  @doc """
  Prompt user for input
  """
  def prompt(message, options \\ []) do
    default = Keyword.get(options, :default)
    required? = Keyword.get(options, :required)
    prompt_string = get_prompt_string(message, options)

    answer =
      prompt_string
      |> Mix.shell().prompt()
      |> String.trim("\n")

    empty? = Enum.member?(@empty_responses, answer)

    cond do
      empty? && default ->
        default

      empty? && required? ->
        print(red("Response required"))
        prompt(message, options)

      true ->
        answer
    end
  end

  defp get_prompt_string(message, options) do
    case Keyword.get(options, :default) do
      nil -> Enum.join([message, "\n"] ++ @prompt)
      default -> Enum.join([message, " ", gray("default is `#{default}`"), "\n"] ++ @prompt)
    end
  end

  @doc """
  Print value to shell

  ## Examples

      print(["\n", IO.ANSI.green(), "✓", IO.ANSI.reset()])
      print(green("✓"))
      print(["😬"])

  """
  def print(value) when is_map(value) do
    value
    |> inspect(pretty: true)
    |> print()
  end

  def print(value), do: Mix.shell().info(value)

  @doc """
  Print an empty line
  """
  def line_break(), do: print("")

  @doc """
  Print a user action callout
  """
  def action(message) do
    print([yellow("Action Required: "), message])

    prompt(["Action completed?", " ", gray("Press enter to continue")])
  end

  @doc """
  Print an error
  """
  def error_message(message) do
    print([red("Error: "), message])
  end

  @doc """
  Print value to shell and exit with error code and red ANSI color output
  """
  def error_message_and_exit(value, code \\ 1)

  def error_message_and_exit(value, code) when is_map(value) do
    value
    |> inspect()
    |> error_message_and_exit(code)
  end

  def error_message_and_exit(value, code) do
    Mix.shell().error(value)

    exit({:shutdown, code})
  end

  @doc """
  Exit task and return code
  """
  def exit_task(code \\ 0), do: exit({:shutdown, code})

  @doc """
  Based on `ExPrompt`: https://github.com/behind-design/ex_prompt/blob/master/lib/ex_prompt.ex

  Asks the user to select form a list of choices.
  It returns either the index of the element in the list
  or -1 if it's not found.

  This method tries first to get said element by the list number,
  if it fails it will attempt to get the index from the list of choices
  by the value that the user wrote.

  ## Examples

    choose("Favorite color?" , ~w(red green blue))
    choose("App?", @apps, default: "artemis")

  """
  def choose(message, choices, options \\ []) do
    message
    |> get_choose_string(options)
    |> print()

    answer =
      Enum.with_index(choices)
      |> Enum.reduce("", fn {c, i}, acc ->
        "#{acc}\s\s#{i + 1}) #{c}\n"
      end)
      |> prompt()

    index =
      try do
        n = String.to_integer(answer)
        if n > 0 and n <= length(choices), do: n - 1, else: -1
      rescue
        _e in ArgumentError ->
          case Enum.find_index(choices, &(&1 == answer)) do
            nil -> -1
            idx -> idx
          end
      end

    cond do
      index > 0 and index <= length(choices) ->
        Enum.at(choices, index)

      default = Keyword.get(options, :default) ->
        default

      true ->
        print(red("Invalid selection `#{answer}`"))
        choose(message, choices)
    end
  end

  defp get_choose_string(message, default: default) do
    [message, " ", gray("default is `#{default}`"), "\n"]
  end

  defp get_choose_string(message, _options) do
    [message, "\n"]
  end
end
