{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()
Artemis.Repo.GenerateData.call()
Ecto.Adapters.SQL.Sandbox.mode(Artemis.Repo, :manual)
