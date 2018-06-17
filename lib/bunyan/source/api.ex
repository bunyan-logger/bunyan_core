defmodule Bunyan.Source.Api do

  @behaviour Bunyan.Source

  use GenServer

  alias Bunyan.{ Collector, Level, LogMsg }

  @compile { :inline, log: 3 }


  @me __MODULE__

  def initialize_source(options) do
    GenServer.start_link(__MODULE__, options, name: @me)
  end

  def init(options) do
    { :ok, options }
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


  @spec log(level :: Level.t(), msg_or_fun :: binary | (() -> binary()) , extra :: any()) :: any()
  defp log(level, msg_or_fun, extra) do
    GenServer.cast(@me, { level, msg_or_fun, extra })
  end

  def handle_cast({ level, msg_or_fun, extra }, options) do
    #if level >= options.runtime_log_level do
      %LogMsg{
        level:     Level.of(level),
        msg:       msg_or_fun,
        extra:     extra,
        timestamp: :os.timestamp(),
        pid:       self(),
        node:      node()
      }
      |> Collector.log()
    #end
    { :noreply, options }
  end
end
