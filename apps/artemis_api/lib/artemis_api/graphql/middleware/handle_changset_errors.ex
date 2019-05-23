defmodule ArtemisApi.GraphQL.Middleware.HandleChangesetErrors do
  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    %{resolution | errors: handle_errors(resolution)}
  end

  def handle_errors(%{errors: errors}) do
    errors
    |> Enum.map(&handle_error/1)
    |> List.flatten()
  end

  defp handle_error(errors) when is_list(errors) do
    errors
    |> Enum.map(&handle_error/1)
    |> List.flatten()
  end

  defp handle_error(%Ecto.Changeset{} = changeset), do: Artemis.Ecto.Helpers.print_errors(changeset)
  defp handle_error(error), do: error
end
