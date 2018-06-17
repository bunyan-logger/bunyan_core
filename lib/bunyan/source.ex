defmodule Bunyan.Source do

  @callback initialize_source(options :: keyword()) :: any()


  def load_all_from_config(config) do
    config
    |> Enum.map(&normalize_source/1)
    |> Enum.each(&start_source/1)
  end

  def normalize_source(source) when is_atom(source) do
    { source, [[]] }
  end

  def normalize_source({ source, options }) do
    { source, options }
  end

  def start_source({ source, options }) do
    apply(source, :initialize_source, [ options ])
  end
end
