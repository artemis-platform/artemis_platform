defmodule ArtemisWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ArtemisWeb, :controller
      use ArtemisWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ArtemisWeb

      import Plug.Conn
      import ArtemisWeb.Gettext
      import ArtemisWeb.Guardian.Helpers
      import ArtemisWeb.Helpers.Controller
      import ArtemisWeb.UserAccess

      alias ArtemisWeb.Router.Helpers, as: Routes

      defp render_format(conn, filename, params) do
        format = get_format(conn)
        conn = render_format_headers(conn, format)

        render(conn, "#{filename}.#{format}", params)
      end

      defp render_format_headers(conn, :csv) do
        filename = Regex.replace(~r/[^a-z0-9_-]+/, conn.request_path, "")

        conn
        |> put_resp_header("content-disposition", "attachment; filename=#{filename}.csv")
        |> put_resp_content_type("text/csv")
      end
      defp render_format_headers(conn, _), do: conn

      defp authorize(conn, permission, render_controller) do
        case has?(conn, permission) do
          true -> render_controller.()
          false -> render_forbidden(conn)
        end
      end

      defp authorize_any(conn, permissions, render_controller) do
        case has_any?(conn, permissions) do
          true -> render_controller.()
          false -> render_forbidden(conn)
        end
      end

      defp authorize_all(conn, permissions, render_controller) do
        case has_all?(conn, permissions) do
          true -> render_controller.()
          false -> render_forbidden(conn)
        end
      end
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/artemis_web/templates",
        namespace: ArtemisWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import ArtemisWeb.Gettext
      import ArtemisWeb.Guardian.Helpers
      import ArtemisWeb.UserAccess
      import ArtemisWeb.ViewData.Layout
      import ArtemisWeb.ViewHelper.Errors
      import ArtemisWeb.ViewHelper.Layout
      import ArtemisWeb.ViewHelper.Tables

      alias ArtemisWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ArtemisWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
