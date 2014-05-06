defmodule Tetris.Mixfile do
  use Mix.Project

  def project do
    [ app: :tetris,
      version: "0.0.1",
      elixir: "~> 0.12.5",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { Tetris, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:cecho, git: "https://github.com/mazenharake/cecho.git", branch: "master"},
      {:quaff, git: "https://github.com/qhool/quaff.git", branch: "master"}
    ]
  end
end
