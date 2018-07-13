defmodule Bunyan.Writer do

  @me __MODULE__

  use DynamicSupervisor

  def load_all_from_config(writers) do
    writers
    |> Enum.each(&add_writer/1)
  end


  def start_link(params) do
    { :ok, _stuff } = DynamicSupervisor.start_link(__MODULE__, params, name: @me)
  end

  def init(_args) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )

  end

  # def stop() do
  #   for {_, pid, _, _} <- Supervisor.which_children(@me) do
  #     GenServer.stop(pid, :normal, @timeout)
  #   end
  #   Supervisor.stop(@me)
  # end

  def add_writer(writer) when is_atom(writer) do
    add_writer({writer, []})
  end

  def add_writer({ writer, opts }) do
    DynamicSupervisor.start_child(@me, { writer, opts })
  end

  def log_message(msg) do
    for { _, pid, _, _ } <- DynamicSupervisor.which_children(@me) do
      GenServer.cast(pid, { :log_message, msg })
    end
    :ok
  end

end
