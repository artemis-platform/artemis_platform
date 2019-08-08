defmodule Artemis.Helpers.UUID do
  @moduledoc """
  Helpers for managing universally unique identifiers
  """

  @hashid_encoder Hashids.new(
                    alphabet: "123456789abdegjklmnopqrvwxyz",
                    min_len: 3
                  )

  @doc """
  Return a random UUID v4 value
  """
  def call() do
    Ecto.UUID.generate()
  end

  @doc """
  Return an encoded using hashids. The same input will always result in the
  same output. The value can be decoded.

  For more information about Hashids see: https://hashids.org
  """
  def encode(id) do
    Hashids.encode(@hashid_encoder, id)
  end

  @doc """
  Return the original id from a hashid.

  For more information about Hashids see: https://hashids.org
  """
  def decode(value) do
    Hashids.decode(@hashid_encoder, value)
  end
end
