defmodule ArtemisWeb.CSV do
  NimbleCSV.define(CustomParser, separator: ",", escape: "\"")

  def create(data) do
    data
    |> CustomParser.dump_to_iodata
    |> IO.iodata_to_binary 
  end
end
