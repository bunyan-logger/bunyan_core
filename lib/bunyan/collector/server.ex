defmodule Bunyan.Collector.Server do
  use GenServer

  alias Bunyan.Collector.State

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(options) do
    { :ok, State.from(options) }
  end

  def handle_cast({ :log, msg }, config) do
    send_to_writers(msg)
    { :noreply, config }
  end

  defp send_to_writers(msg = %{ msg: fun }) when is_function(fun) do
    send_to_writers(%{ msg | msg: fun.()})
  end

  defp send_to_writers(msg) do
    Bunyan.Writer.log_message(msg)
  end


end
