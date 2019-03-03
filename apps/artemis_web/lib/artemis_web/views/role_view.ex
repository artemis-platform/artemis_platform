defmodule ArtemisWeb.RoleView do
  use ArtemisWeb, :view

  import Artemis.Helpers, only: [keys_to_atoms: 2]
  import Scrivener.HTML

  alias Artemis.Permission

  @doc """
  Returns a matching `permission` record based on the passed `permission.id` match value.

  The `permission` data could come from:

  1. The existing record in the database.
  2. The existing form data.

  If the form has not been submitted, it uses the existing record data in the database.

  Once the form is submitted, the existing form data takes precedence. This
  ensures new values are not lost when the form is reloaded after an error.
  """
  def find_permission(match, form, record) do
    existing_permissions = record.permissions
    submitted_permissions = case form.params["permissions"] do
      nil -> nil
      values -> Enum.map(values, &struct(Permission, keys_to_atoms(&1, [])))
    end

    permissions = submitted_permissions || existing_permissions

    Enum.find(permissions, fn (%{id: id}) ->
      id = case is_bitstring(id) do
        true -> String.to_integer(id)
        _ -> id
      end

      id == match
    end)
  end
end
