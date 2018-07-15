defmodule BunyanCore.Application do

  use Application

  def start(_type, _args) do

    config =  Application.get_all_env(:bunyan)

    children = [
      BunyanCore.Writer,
      BunyanCore.Collector.Server,
      BunyanCore.Source,
      { BunyanCore.Kickoff, config },
    ]

    opts = [strategy: :one_for_one, name: BunyanCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
