defmodule Bunyan.Collector do


  alias Bunyan.Collector.Server

    def maybe_log(log_msg) do
    GenServer.cast(Server, { :log, log_msg })
  end

  def maybe_report(log_msg) do
    GenServer.cast(Server, { :log, log_msg })
  end
end
