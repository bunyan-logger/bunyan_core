defmodule Bunyan.Writers.Remote.Server do

  use GenServer

  alias Bunyan.Writers.Remote.{ Impl, State }

  @me __MODULE__

  def start_link(args) do
    GenServer.start_link(__MODULE__, Impl.parse_options(args), name: @me)
  end

  def init(args) do
    raise inspect here: args
    state = %State{} |> reset_timer()
    { :ok, state }
  end


  def handle_cast({ :send, msg }, state) do
    state = maybe_send(msg, state)
    { :noreply, state }
  end


  defp maybe_send(msg, state = %{ pending: pending }) do
    state = %{ state | pending: [ msg | pending ]}

    cond do
      length(state.pending) >= state.max_pending_size ->
        send_and_reset(state)
      true ->
        state
    end
  end

  defp send_and_reset(state) do
    GenServer.call(state.target_process, { :forward_log, Enum.reverse(state.pending) })
    state
    |> reset_timer()
    |> Map.put(:pending, [])
  end

  defp reset_timer(state) do
    if state.timer_ref, do: Process.cancel_timer(state.timer_ref)
    ref = Process.send_after(self(), { :flush }, state.max_pending_wait)
    %{ state | timer_ref: ref }
  end

  def handle_info({ :flush }, state) do
    state = state |> send_and_reset()
    { :noreply, state }
  end
end
