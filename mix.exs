defmodule Bunyan.MixProject do
  use Mix.Project

  def project do
    [
      app:     :bunyan,
      version: "0.1.0",
      elixir:  "~> 1.6",
      deps:    deps(System.get_env("BUNYAN_DEVELOPER")),
      start_permanent: Mix.env() == :prod,
    ]
  end

  def application do
    [
      mod: {
        Bunyan.Application, []
      },
    ]
  end

  # not a Bunyan developer, so use hex
  defp deps(nil) do
        [
          bunyan_shared: "~> 0.0.0",
        ]
      end

  # otherwise use path dependencies
  defp deps(_) do
    [
      { :bunyan_shared, path: "../bunyan_shared" },
    ]
  end
end
