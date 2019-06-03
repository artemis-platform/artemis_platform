defmodule Artemis.Helpers.UUID do
  def call() do
    Ecto.UUID.generate()
  end
end
