defmodule Bunyan.Source.Api do

  @behaviour Bunyan.Source

  alias Bunyan.{ Collector, Level, LogMsg }

  def initialize_source(_options) do
    nil
  end


  def debug(msg_or_fun, extra) do
    log(:debug, msg_or_fun, extra)
  end

  def info(msg_or_fun, extra) do
    log(:info, msg_or_fun, extra)
  end

  def warn(msg_or_fun, extra) do
    log(:warn, msg_or_fun, extra)
  end

  def error(msg_or_fun, extra) do
    log(:error, msg_or_fun, extra)
  end

  defp log(level, msg_or_fun, extra) do
    %LogMsg{
      level:     Level.of(level),
      msg:       msg_or_fun,
      extra:     extra,
      timestamp: :os.timestamp(),
      pid:       self(),
      node:      node()
    }
    |> Collector.maybe_log()
  end
end
