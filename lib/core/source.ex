defmodule BunyanCore.Source do


  @me __MODULE__

  use DynamicSupervisor

  def load_all_from_config(config, collector) do
    config
    |> Enum.map(&normalize_source/1)
    |> Enum.each(&add_source(collector, &1))
  end

  def start_link(params) do
    { :ok, _stuff } = DynamicSupervisor.start_link(__MODULE__, params, name: @me)
  end

  def init(_params) do
    { :ok, _options } = DynamicSupervisor.init(strategy: :one_for_one)
  end

  def normalize_source(source) when is_atom(source), do: { source, [] }
  def normalize_source({ source, options }),         do: { source, options }


  @spec add_source(module :: atom(), { module :: atom(), options :: keyword() }) :: any()

  def add_source(collector, { source, options }) do
    { :ok, _pid } = DynamicSupervisor.start_child(@me, { source, { collector, options }})
  end

end
