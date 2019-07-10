defmodule Artemis.Context do
  defmodule Error do
    defexception message: "Context Error"
  end

  defmacro __using__(options) do
    quote do
      use Artemis.ContextCache,
        cache_reset_events: Keyword.get(unquote(options), :cache_reset_events, [])

      import Artemis.Context
      import Artemis.Repo.Helpers
      import Artemis.Repo.Order
      import Artemis.UserAccess

      alias Artemis.CacheInstance
      alias Artemis.Event
    end
  end
end
