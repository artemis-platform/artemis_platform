defmodule ArtemisWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest

      import ArtemisWeb.ConnHelpers

      alias ArtemisWeb.Mock
      alias ArtemisWeb.Router.Helpers, as: Routes

      @endpoint ArtemisWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Artemis.Repo)
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ArtemisLog.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Artemis.Repo, {:shared, self()})
      Ecto.Adapters.SQL.Sandbox.mode(ArtemisLog.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
