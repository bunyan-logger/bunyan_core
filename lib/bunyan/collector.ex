defmodule Bunyan.Collector do


  alias Bunyan.Collector.Server

   def log(log_msg) do
    GenServer.cast(Server, { :log, log_msg })
  end

  def report(log_msg) do
    GenServer.cast(Server, { :log, log_msg })
  end
end
