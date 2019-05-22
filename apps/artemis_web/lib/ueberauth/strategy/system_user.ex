defmodule Ueberauth.Strategy.SystemUser do
  @moduledoc """
  A demo/development only authentication strategy for Ueberauth to log in as the
  System User.
  """

  use Ueberauth.Strategy,
    uid_field: :email,
    email_field: :email,
    name_field: :name,
    first_name_field: :first_name,
    last_name_field: :last_name,
    nickname_field: :nickname,
    phone_field: :phone,
    location_field: :location,
    description_field: :description,
    param_nesting: nil,
    scrub_params: true

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Extra

  def uid(_conn) do
    get_system_user().email
  end

  def info(conn) do
    struct(
      Info,
      email: get_system_user().email,
      name: get_system_user().name,
      first_name: param_for(conn, :first_name_field),
      last_name: param_for(conn, :last_name_field),
      nickname: param_for(conn, :nickname_field),
      phone: param_for(conn, :phone_field),
      location: param_for(conn, :location_field),
      description: param_for(conn, :description_field)
    )
  end

  def extra(conn) do
    struct(Extra, raw_info: conn.params)
  end

  defp option(conn, name) do
    Keyword.get(options(conn), name, Keyword.get(default_options(), name))
  end

  defp param_for(conn, name) do
    param_for(conn, name, option(conn, :param_nesting))
  end

  defp param_for(conn, name, nil) do
    conn.params
    |> Map.get(to_string(option(conn, name)))
    |> scrub_param(option(conn, :scrub_params))
  end

  defp param_for(conn, name, nesting) do
    attrs =
      nesting
      |> List.wrap()
      |> Enum.map(fn item -> to_string(item) end)

    case Kernel.get_in(conn.params, attrs) do
      nil ->
        nil

      nested ->
        nested
        |> Map.get(to_string(option(conn, name)))
        |> scrub_param(option(conn, :scrub_params))
    end
  end

  defp scrub_param(param, false), do: param
  defp scrub_param(param, _) do
    if scrub?(param), do: nil, else: param
  end

  defp scrub?(" " <> rest), do: scrub?(rest)
  defp scrub?(""), do: true
  defp scrub?(_), do: false

  defp get_system_user do
    Application.fetch_env!(:artemis, :users)[:system_user]
  end
end
