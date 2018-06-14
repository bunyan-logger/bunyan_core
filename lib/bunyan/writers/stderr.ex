defmodule Bunyan.Writers.Stderr do

  alias Bunyan.Writers.Stderr.{ Formatter, State }

  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    { :ok, State.from_options(options) }
  end

  def handle_cast({ :log_message, msg}, options) do
    IO.inspect options
    IO.inspect msg
    #IO.write(:standard_error, options.format_function(msg, options))
    { :noreply, options }
  end
end
