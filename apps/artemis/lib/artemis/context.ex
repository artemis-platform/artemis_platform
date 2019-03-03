defmodule Artemis.Context do
  defmodule Error do
    defexception message: "Context Error"
  end

  defmacro __using__(_opts) do
    quote do
      import Artemis.Context
      import Artemis.Repo.Helpers
      import Artemis.UserAccess

      alias Artemis.Event
    end
  end
end
