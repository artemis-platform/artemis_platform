defmodule ArtemisWeb.SessionView do
  use ArtemisWeb, :view

  def get_provider_color(%{title: title}) do
    case title do
      "Facebook" -> "blue"
      "Google" -> "teal"
      _ -> "gray"
    end
  end
end
