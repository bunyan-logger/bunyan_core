defmodule Bunyan.Writers.Stderr do

  alias Bunyan.Writers.Stderr.State
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    { :ok, State.from_options(options) }
  end

  def handle_cast({ :log_message, {level, msg, meta, time, pid, node }}, state) do
    #{ :noreply, format(msg, state) }
  end
end
