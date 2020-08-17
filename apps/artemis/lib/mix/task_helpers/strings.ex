defmodule Mix.TaskHelpers.Strings do
  @doc """
  Downcase a string
  """
  def lowercase(value), do: String.downcase(value)

  @doc """
  Sentence case a string
  """
  def sentencecase(value), do: String.capitalize(value)

  @doc """
  Upcase a string
  """
  def uppercase(value), do: String.upcase(value)

  @doc """
  Pascal Case a string
  """
  def pascalcase(word, option \\ :upper) do
    case Regex.split(~r/(?:^|[-_])|(?=[A-Z])/, to_string(word)) do
      words ->
        words
        |> Enum.filter(&(&1 != ""))
        |> camelize_list(option)
        |> Enum.join()
    end
  end

  defp camelize_list([], _), do: []

  defp camelize_list([h | tail], :lower) do
    [String.downcase(h)] ++ camelize_list(tail, :upper)
  end

  defp camelize_list([h | tail], :upper) do
    [String.capitalize(h)] ++ camelize_list(tail, :upper)
  end

  @doc """
  Returns a snakecase string. Example:

      Input: "HelloWorld"
      Ouput: "hello_world"
  """
  def snakecase(value) when is_bitstring(value) do
    Macro.underscore(value)
  end

  @doc """
  Returns a dashcase string. Example:

      Input: "HelloWorld"
      Ouput: "hello-world"
  """
  def dashcase(value) do
    value
    |> snakecase()
    |> String.replace("_", "-")
  end

  @doc """
  Returns a spacecase string. Example:

      Input: "HelloWorld"
      Ouput: "hello world"
  """
  def spacecase(value) do
    value
    |> snakecase()
    |> String.replace("_", " ")
  end

  @doc """
  Module case a string
  """
  def modulecase(value) do
    value
    |> String.downcase()
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end
end
