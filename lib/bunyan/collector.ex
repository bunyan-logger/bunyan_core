defmodule Bunyan.Collector do

  @collector Bunyan.Collector.Server

  def maybe_log(msg = {_level, _msg_or_fun, _meta}) do
    GenServer.cast(@collector, { :log, msg, self(), node() })
  end

end
