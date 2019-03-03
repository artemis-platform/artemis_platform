defmodule ArtemisApi.Session do
  @derive {Jason.Encoder, only: []}

  defstruct [
    :token,
    :token_creation,
    :token_expiration,
    :user
  ]
end
