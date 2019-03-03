defmodule ArtemisApi.CreateSession do
  alias ArtemisApi.Guardian
  alias ArtemisApi.Session

  def call(user) do
    case Guardian.encode_and_sign(user) do
      {:ok, token, token_info} ->
        {:ok, create_session(user, token, token_info)}
      error ->
        error
    end
  end

  defp create_session(user, token, %{"exp" => token_expiration}) do
    %Session{
      token: token,
      token_creation: DateTime.utc_now |> DateTime.to_unix |> to_string,
      token_expiration: token_expiration,
      user: user
    }
  end
end
