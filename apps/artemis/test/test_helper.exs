{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Artemis.Repo.Seeds.call()
Ecto.Adapters.SQL.Sandbox.mode(Artemis.Repo, :manual)
