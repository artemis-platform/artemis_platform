{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Atlas.Repo.Seeds.call()
Ecto.Adapters.SQL.Sandbox.mode(Atlas.Repo, :manual)
