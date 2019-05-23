defmodule ArtemisWeb.Guardian do
  use Guardian, otp_app: :artemis_web

  alias Artemis.GetUser
  alias Artemis.GetSystemUser

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, "Error creating token"}
  end

  def resource_from_claims(%{"sub" => id}) do
    system_user = GetSystemUser.call!()
    resource = GetUser.call(id, system_user, preload: [:permissions])

    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, "Error reading token"}
  end
end
