defmodule Bunyan.Writer.Device.State do

  alias Bunyan.Level
  alias Bunyan.Writer.Device.{ Formatter, Impl }

  @debug Level.of(:debug)
  @info  Level.of(:info)
  @warn  Level.of(:warn)
  @error Level.of(:error)

  import IO.ANSI

  defstruct(
    # `name` is the name or pid of this partiular device gen_server.
    # `device_pid` (below) is the pid of the corresponding I/O handled.

    name:          Bunyan.Writer.Device,

    device:        :user,          # a pid, a named process (eg :user), or a filename
    device_pid:    :user,          # the opened device

    pid_file_name: nil,

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

    user_wants_color?: true,      # this is the user option
    use_ansi_color?:   true       # and this is (user_wants_color? && device supports it)
  )

  def from_options(user_options, base \\ %__MODULE__{}) do
    options = base
              |> maybe_add(user_options, :name)
              |> maybe_add(user_options, :device)
              |> maybe_add(user_options, :pid_file_name)
              |> maybe_add(user_options, :main_format_string)
              |> maybe_add(user_options, :additional_format_string)
              |> maybe_add(user_options, :timestamp_color)
              |> maybe_add(user_options, :extra_color)
              |> maybe_add(user_options, :use_ansi_color?, :user_wants_color?)
              |> maybe_update_colors(user_options, :level_colors)
              |> maybe_update_colors(user_options, :message_colors)

    Impl.set_log_device(options, options.device)
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

  def maybe_add(config, options, key, internal_key \\ nil) do
    case options[key] do
      nil ->
        config
      value ->
        Map.put(config, internal_key || key , value)
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
