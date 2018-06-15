defmodule Bunyan.Source.ErlangErrorLogger do

  @behaviour Bunyan.Source

  alias Bunyan.Source.ErlangErrorLogger.EventHandler

  def initialize_source(options) do
    state = swap_error_handlers(options)
    { :ok, state }
  end

  defp swap_error_handlers(options) do
    :gen_event.swap_handler(
      :error_logger,
      { :error_logger_tty_h, [] },
      { EventHandler, options }
    )
  end
end
