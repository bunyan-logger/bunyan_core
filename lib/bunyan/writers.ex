defmodule Bunyan.Writers do

  @timeout 30_000
  @me __MODULE__

  use Supervisor

  # stolen from
  # http://blog.plataformatec.com.br/2016/11/replacing-genevent-by-a-supervisor-genserver/

  def start_link(params) do
    children = [
      {
        DynamicSupervisor,
        name:      @me,
        strategy: :one_for_one,
        extra_arguments: params
      }
    ]

    { :ok, _stuff } = Supervisor.start_link(children, strategy: :one_for_one)
  end


  def stop() do
    for {_, pid, _, _} <- Supervisor.which_children(@me) do
      GenServer.stop(pid, :normal, @timeout)
    end
    Supervisor.stop(@me)
  end

  def add_writer(writer) when is_atom(writer) do
    add_writer({writer, []})
  end

  def add_writer({ writer, opts }) do
    IO.inspect add_writer: { writer, opts }
    IO.inspect DynamicSupervisor.start_child(@me, { writer, opts })
  end

  def log_message(msg = {_level, _msg, _meta, _time, _pid, _node}) do
    notify({:log_message, msg})
  end

  defp notify(msg = { _function, __log_message }) do
    for {_, pid, _, _} <- DynamicSupervisor.which_children(@me) do
      GenServer.cast(pid, msg)
    end
    :ok
  end

  def handle_info(:start_writers, state) do
    raise inspect {:info, state}
  end

  def init(args) do
    raise inspect args
  end
end
