defmodule ArtemisApi.GraphQL.Resolver.Info do
  # Queries

  def info(_params, _context) do
    release_branch = Application.get_env(:artemis_api, :release_branch)
    release_hash = Application.get_env(:artemis_api, :release_hash)

    data = %{
      release_branch: release_branch,
      release_hash: release_hash,
      release_version: release_branch <> "-" <> release_hash
    }

    {:ok, data}
  end
end
