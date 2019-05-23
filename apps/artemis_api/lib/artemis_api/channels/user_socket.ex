defmodule ArtemisApi.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "room:*", ArtemisApi.RoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket, _connect_info) do
    case get_user(params) do
      {:ok, user} -> {:ok, assign(socket, :user, user)}
      _ -> :error
    end
  end

  defp get_user(%{"token" => token}) do
    case decode_token(token) do
      {:ok, claims} -> ArtemisApi.Guardian.resource_from_claims(claims)
      {:error, _} -> {:error, "Error decoding user token"}
    end
  end

  defp get_user(_), do: :error

  defp decode_token(token) do
    Guardian.decode_and_verify(ArtemisApi.Guardian, token, %{}, [])
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ArtemisApi.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
