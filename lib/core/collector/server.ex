defmodule BunyanCore.Collector.Server do
  use GenServer

  alias BunyanCore.Collector.State

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(options) do
    { :ok, State.from(options) }
  end

  def handle_cast({ :log, msg }, config) do
    maybe_demux_messages(msg)
    { :noreply, config }
  end

  def handle_cast(other, config) do
    IO.puts "unexpected cast to Collector"
    IO.inspect cast: other
    IO.inspect cast: config
    :erlang.halt
  end


  defp maybe_demux_messages(msgs) when is_list(msgs) do
    msgs
    |> Enum.each(&send_to_writers/1)
  end

  defp maybe_demux_messages(msg) do
    send_to_writers(msg)
  end

  defp send_to_writers(msg = %{ msg: fun }) when is_function(fun) do
    send_to_writers(%{ msg | msg: fun.()})
  end

  defp send_to_writers(msg) do
    BunyanCore.Writer.log_message(msg)
  end


end
