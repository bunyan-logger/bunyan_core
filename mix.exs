defmodule Bunyan.MixProject do
  use Mix.Project

  def project do
    [
      app:     :bunyan,
      version: "0.1.0",
      elixir:  "~> 1.6",
      deps:    [ ],
      start_permanent: Mix.env() == :prod,
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Bunyan.Application, []},
      env: env(),
    ]
  end

  defp env() do
    [
      name:             MyLogger,
      accept_remote_as: GlobalLogger,
      min_log_level:    :info,
      write_to:         [
        { Bunyan.Writers.Stderr, [] },
        #{ Bunyan.Writers.Remote, [ send_to: YourLogger, min_log_level: :warn ] },
      ]
    ]
  end
end
