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

  @debug  0
  @info  10
  @warn  20
  @error 30

  defp env() do
    import IO.ANSI

    [
      name:             MyLogger,
      accept_remote_as: GlobalLogger,
      min_log_level:    :debug,
      read_from:        [
        Bunyan.Source.Api,
        Bunyan.Source.ErlangErrorLogger,
      ],
      write_to:         [
        {
          Bunyan.Writer.Stderr, [
            main_format_string:        "$time [$level] $message_first_line",
            additional_format_string:  "$message_rest\n$extra",

            level_colors:   %{
              @debug => faint(),
              @info  => green(),
              @warn  => yellow(),
              @error => light_red() <> bright()
            },
            message_colors: %{
              @debug => faint(),
              @info  => reset(),
              @warn  => yellow(),
              @error => light_red() <> bright()
            },
            timestamp_color: faint(),
            extra_color:     italic() <> faint(),

            use_ansi_color?: true

          ]
        },
        #{ Bunyan.Writers.Remote, [ send_to: YourLogger, min_log_level: :warn ] },
      ]
    ]
  end
end
