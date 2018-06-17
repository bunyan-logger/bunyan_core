defmodule Bunyan.Writer.Device do

  @moduledoc """
  Write log messages to an IO device. We operate as a separate process
  to allow the rest to continue asynchronously.
  """

  # TODO update to store device

  use GenServer
  alias __MODULE__.State

  @doc false
  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  @doc false
  def init(options) do
    { :ok, State.from_options(options) }
  end

  @doc false
  def handle_cast({ :log_message, msg}, options) do
    IO.write(:standard_error, options.format_function.(msg) |> List.flatten |> Enum.join)
    { :noreply, options }
  end
end
