defmodule ArtemisWeb.UserImpersonationView do
  use ArtemisWeb, :view

  import Artemis.Helpers, only: [keys_to_atoms: 2]

  alias Artemis.UserRole

  @doc """
  Returns a matching `user_role` record based on the passed `role.id` match value.

  The `user_role` data could come from:

  1. The existing record in the database.
  2. The existing form data.

  If the form has not been submitted, it uses the existing record data in the database.

  Once the form is submitted, the existing form data takes precedence. This
  ensures new values are not lost when the form is reloaded after an error.
  """
  def find_user_role(match, form, record) do
    existing_user_roles = record.user_roles
    submitted_user_roles = case form.params["user_roles"] do
      nil -> nil
      values -> Enum.map(values, &struct(UserRole, keys_to_atoms(&1, [])))
    end

    user_roles = submitted_user_roles || existing_user_roles

    Enum.find(user_roles, fn (%{role_id: role_id}) ->
      role_id = case is_bitstring(role_id) do
        true -> String.to_integer(role_id)
        _ -> role_id
      end

      role_id == match
    end)
  end
end
