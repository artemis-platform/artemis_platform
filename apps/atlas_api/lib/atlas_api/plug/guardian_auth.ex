defmodule AtlasApi.Plug.GuardianAuth do
  use Guardian.Plug.Pipeline,
    otp_app: :atlas_api,
    module: AtlasApi.Guardian,
    error_handler: AtlasApi.Guardian.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
