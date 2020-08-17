defmodule Mix.TaskHelpers.Commands do
  @moduledoc """
  Functions to make system calls and execute commands

  Note: Uses `:os.cmd` instead of `System.cmd`
  """

  @doc """
  Execute a command using `sh`
  """
  def execute(command) do
    command
    |> String.to_charlist()
    |> :os.cmd()
    |> List.to_string()
    |> String.trim_trailing("\n")
  end
end
