defmodule Tetris.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tetris,
      version: "0.0.1",
      elixir: "~> 1.9",
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [all_tests: :test]
    ]
  end

  # Configuration for the OTP application
  def application do
    [mod: {Tetris, []}]
  end

  defp deps do
    [
      {:matrix, "~> 0.3.2"},
      {:credo, "~> 1.1", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      all_tests: [
        "format --check-formatted",
        "compile --force --warnings-as-errors",
        "test"
      ]
    ]
  end
end
