defmodule Bunyan.Writer.Stderr.State do

  alias Bunyan.Level
  alias Bunyan.Writer.Stderr.Formatter

  @debug Level.of(:debug)
  @info  Level.of(:info)
  @warn  Level.of(:warn)
  @error Level.of(:error)

  import IO.ANSI

  defstruct(
    main_format_string:        "$time [$level] $message_first_line",
    additional_format_string:  "$message_rest\n$extra",

    format_function:           nil,

    level_colors:   %{
      @debug => faint(),
      @info  => green(),
      @warn  => yellow(),
      @error => light_red() <> bright()
    },
    message_colors: %{
      @debug => faint(),
      @info  => reset(),
      @warn  => yellow(),
      @error => light_red() <> bright()
    },
    timestamp_color: faint(),
    extra_color:     italic() <> faint(),

    use_ansi_color?: true
  )

  def from_options(options) do
    %__MODULE__{}
    |> maybe_add(options, :main_format_string)
    |> maybe_add(options, :additional_format_string)
    |> maybe_add(options, :timestamp_color)
    |> maybe_add(options, :extra_color)
    |> maybe_add(options, :use_ansi_color?)
    |> maybe_update_colors(options, :level_colors)
    |> maybe_update_colors(options, :message_colors)
    |> precompile_format_function()
  end

  def precompile_format_function(options) do
    function = Formatter.compile_format(
      options.main_format_string,
      options.additional_format_string,
      options
    )

    %{ options | format_function: function}
  end

  def maybe_add(config, options, key) do
    case options[key] do
      nil ->
        config
      value ->
        Map.put(config, key, value)
    end
  end

  def maybe_update_colors(config, options, key) do
    add_specific_colors(config, options[key], key)
  end

  def add_specific_colors(config, nil, _), do: config
  def add_specific_colors(config, colors, key) do
    original = Map.get(config, key)
    updated  =
       [ @debug, @info, @warn, @error ]
       |> Enum.reduce(original, fn level, updated ->
            maybe_add_to_map(updated, level, colors[Level.to_atom(level)])
          end)

    Map.put(config, key, updated)
  end

  defp maybe_add_to_map(map, _key, nil), do: map
  defp maybe_add_to_map(map,  key, val), do: Map.put(map, key, val)
end
