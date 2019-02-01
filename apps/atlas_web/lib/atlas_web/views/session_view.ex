defmodule AtlasWeb.SessionView do
  use AtlasWeb, :view

  def get_provider_color(%{title: title}) do
    case title do
      "IBM W3ID" -> "blue"
      _ -> "gray"
    end
  end
end
