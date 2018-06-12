defmodule Bunyan.Collector.Server do
  use GenServer

  alias Bunyan.Collector.State

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(_options) do
    { :ok, %State{ } }
  end

  def handle_cast({ :log, { level, msg_or_fun, meta }}, config) do
    if level >= config.minimum_level_to_report do
      send_to_writers(level, msg_or_fun, meta, :os.timestamp())
    end

    { :noreply, config }
  end

  defp send_to_writers(level, fun, meta, time) when is_function(fun) do
    send_to_writers(level, fun.(), meta, time)
  end

  defp send_to_writers(level, msg, meta, time) do
    Bunyan.Writers.log_message({ level, msg, meta, time })
  end


end
