defmodule ArtemisApi.GraphQL.Schema.Scalars do
  defmacro __using__(_opts) do
    quote do
      scalar :time, description: "ISOz time" do
        parse(&Timex.parse(&1.value, "{ISO:Extended:Z}"))
        serialize(&Timex.format!(&1, "{ISO:Extended:Z}"))
      end

      scalar :json, description: "JSON encoded value" do
        parse(fn input ->
          case Poison.decode(input.value) do
            {:ok, result} -> result
            _ -> :error
          end
        end)

        serialize(&Poison.encode!/1)
      end
    end
  end
end
