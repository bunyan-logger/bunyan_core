defmodule Bunyan.Writers.Stderr do

  use GenServer

  def start_link(options) do
    IO.inspect stderr: options
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    { :ok, options }
  end

  def handle_cast({ :log_message, {level, msg, meta, time, pid, node }}, state) do
    #{ :noreply, format(msg, state) }
  end
end
