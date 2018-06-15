defmodule Bunyan.Writer.Stderr do

  use GenServer
  alias __MODULE__.State

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    { :ok, State.from_options(options) }
  end

  def handle_cast({ :log_message, msg}, options) do
    IO.write(options.format_function.(msg) |> List.flatten |> Enum.join)
    { :noreply, options }
  end
end
