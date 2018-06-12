defmodule Bunyan.Sources.Api do

  alias Bunyan.{ Collector, Level }

  def debug(msg_or_fun, meta) do
    Collector.maybe_log({ Level.of(:debug), msg_or_fun, meta })
  end

  def info(msg_or_fun, meta) do
    Collector.maybe_log({ Level.of(:info), msg_or_fun, meta })
  end

  def warn(msg_or_fun, meta) do
    Collector.maybe_log({ Level.of(:warn), msg_or_fun, meta })
  end

  def error(msg_or_fun, meta) do
    Collector.maybe_log({ Level.of(:error), msg_or_fun, meta })
  end

end
