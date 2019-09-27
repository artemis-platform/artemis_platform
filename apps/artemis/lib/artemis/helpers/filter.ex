defmodule Artemis.Helpers.Filter do
  @default_delimiter ","

  def split(value, delimiter \\ @default_delimiter)
  def split(value, delimiter) when is_bitstring(value), do: String.split(value, delimiter)
  def split(value, delimiter) when is_atom(value), do: split(Atom.to_string(value), delimiter)
  def split(value, _delimiter) when is_list(value), do: value
  def split(value, _delimiter), do: [value]
end
