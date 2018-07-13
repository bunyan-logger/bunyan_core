defmodule Bunyan.Application do

  use Application

  def start(_type, _args) do

    config =  Application.get_all_env(:bunyan)

    children = [
      Bunyan.Writer,
      Bunyan.Collector.Server,
      Bunyan.Source,
      { Bunyan.Kickoff, config },
    ]

    opts = [strategy: :one_for_one, name: Bunyan.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
