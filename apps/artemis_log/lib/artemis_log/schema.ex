defmodule ArtemisLog.Schema do
  @callback fields :: List.t
  @callback required :: List.t

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias __MODULE__
      alias ArtemisLog.Repo
      alias ArtemisLog.Schema
    end
  end
end
