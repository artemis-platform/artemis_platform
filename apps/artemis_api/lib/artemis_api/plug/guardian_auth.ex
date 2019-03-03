defmodule ArtemisApi.Plug.GuardianAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :artemis_api,
    module: ArtemisApi.Guardian,
    error_handler: ArtemisApi.Guardian.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
