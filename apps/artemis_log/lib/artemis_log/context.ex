defmodule ArtemisLog.Context do
  defmodule Error do
    defexception message: "Context Error"
  end

  defmacro __using__(_opts) do
    quote do
      import Artemis.UserAccess
      import ArtemisLog.Context
      import ArtemisLog.Repo.Order
    end
  end
end
