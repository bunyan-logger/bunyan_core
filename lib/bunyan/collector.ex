defmodule Bunyan.Collector do


  alias Bunyan.{Collector.Server, LogMsg}

  def maybe_log({level, msg_or_fun, extra}) do
    log_msg = %LogMsg{
      level:     level,
      msg:       msg_or_fun,     # function is resolved in the server process
      extra:     extra,
      timestamp: :os.timestamp(),
      pid:       self(),
      node:      node()
    }

    GenServer.cast(Server, { :log, log_msg })
  end

end
