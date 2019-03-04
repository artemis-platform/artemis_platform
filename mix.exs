defmodule Artemis.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    []
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Run each umbrella applications tests independently. Similar to doing:
      #
      #   cd apps/app_01 && mix test
      #   cd apps/app_02 && mix test
      #
      # With standard `mix test` in an umbrella app, the BEAM VM is reused between tests.
      # This can lead to one application leaking into another. Forcing
      # independent tests is a safe guard against flakey test failures and
      # ensures all applications are independent and self sufficient
      #
      # For futher discussion see: https://elixirforum.com/t/mix-test-in-an-umbrella/10771
      test: ["cmd mix test --color"]
    ]
  end
end
