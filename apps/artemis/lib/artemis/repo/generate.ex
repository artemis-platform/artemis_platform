defmodule Artemis.Repo.GenerateData do
  @verification_phrase "confirming-generation-of-filler-data"

  import Artemis.Factories

  def call(verification_phrase) do
    case verification_phrase == @verification_phrase do
      true -> {:ok, generate_data()}
      false -> {:error, "Verification phrase required"}
    end
  end

  defp generate_data do
    insert_list(30, :user)
  end
end

