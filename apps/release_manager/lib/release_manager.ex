defmodule ReleaseManager do
  def migrate do
    init(fn apps ->
      :ok = migrate_repositories(apps)
    end)
  end

  ## Private functions

  defp init(fun) do
    :ok = start_dependencies()
    apps = get_and_load_applications()
    repos = start_repositories(apps)

    fun.(apps)

    :ok = stop_repositories(repos)
    :init.stop()
  end

  defp start_dependencies do
    {:ok, _} = Application.ensure_all_started(:release_manager)
    :ok
  end

  defp get_and_load_applications do
    apps = Application.get_env(:release_manager, :apps, [])
    for {app, _repo} <- apps, do: Application.load(app)
    apps
  end

  defp migrate_repositories(apps) do
    for app <- apps, do: migrate_repository(app)
    :ok
  end

  defp migrate_repository({app, repo}) do
    path = Application.app_dir(app, "priv/repo/migrations")
    Ecto.Migrator.run(repo, path, :up, all: true)
    :ok
  end

  defp start_repositories(apps) do
    for {_app, repo} <- apps do
      {:ok, pid} = repo.start_link()
      {pid, repo}
    end
  end

  defp stop_repositories(repos) do
    for {pid, repo} <- repos do
      repo.stop(pid)
    end

    :ok
  end
end
