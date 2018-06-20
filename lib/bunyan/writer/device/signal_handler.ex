defmodule Bunyan.Writer.Device.SignalHandler do

  @behaviour :gen_event

  alias Bunyan.Writer.Device

  def start(writer_pid) do
    if !already_added?() do
      :gen_event.delete_handler(:erl_signal_server, :erl_signal_handler, [])
      :gen_event.add_handler(:erl_signal_server, __MODULE__, writer_pid)
    end
  end

  def init(writer_pid) do
    { :ok, writer_pid }
  end

  def kill() do
    if already_added?() do
      :gen_event.add_handler(:erl_signal_server, :erl_signal_handler, [])
      :gen_event.delete_handler(:erl_signal_server, __MODULE__, [])
    end
  end

  def handle_event(:sigusr1, writer_pid) do
    Device.bounce_log_file(writer_pid)
    { :ok, writer_pid }
  end

  def handle_event(other, options) do
    :erl_signal_handler.handle_event(other, options)
  end

  def handle_call(_, options) do
    { :ok, :ok, options }
  end


  defp already_added?() do
    __MODULE__ in :gen_event.which_handlers(:erl_signal_server)
  end
end
