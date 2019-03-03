defmodule ArtemisApi.GraphQL.Resolver.Info do

  # Queries

  def info(_params, _context) do
    data = %{
      release_branch: Application.get_env(:artemis_api, :release_branch),
      release_hash: Application.get_env(:artemis_api, :release_hash),
      release_version: Application.get_env(:artemis_api, :release_branch) <> "-" <> Application.get_env(:artemis_api, :release_hash)
    }

    {:ok, data}
  end
end
