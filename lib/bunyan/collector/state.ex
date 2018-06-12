defmodule Bunyan.Collector.State do


  defstruct(
    minimum_level_to_report: Bunyan.Level.info(),
    log_hosts:               []                   # where to send messages
  )
end
