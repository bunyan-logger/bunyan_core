defmodule TestHelpers do

  @xmas_seconds (:calendar.datetime_to_gregorian_seconds({{2020, 12, 25}, { 12, 34, 56 }}) - 62167219200)
  @xmas { div(@xmas_seconds, 1_000_000), rem(@xmas_seconds, 1_000_000), 123_456 }

  @debug Bunyan.Level.of(:debug)
  @info  Bunyan.Level.of(:info)
  @warn  Bunyan.Level.of(:warn)
  @error Bunyan.Level.of(:error)


  def msg(level \\ @debug, msg, extra \\ nil, timestamp \\ @xmas, pid \\ :a_pid, node \\ :a_node) do
    %Bunyan.LogMsg{
      level:     level,
      msg:       msg,
      extra:     extra,
      timestamp: timestamp,
      pid:       pid,
      node:      node
    }
  end
end

ExUnit.start()
