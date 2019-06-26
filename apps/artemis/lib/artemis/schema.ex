defmodule Artemis.Schema do
  @callback required_fields :: List.t()
  @callback updatable_fields :: List.t()

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias __MODULE__
      alias Artemis.Repo
      alias Artemis.Schema

      @behaviour Artemis.Schema
    end
  end
end
