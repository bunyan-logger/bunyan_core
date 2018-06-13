defmodule Bunyan.Writers.Stderr.State do

  alias Bunyan.Level

  @debug Level.of(:debug)
  @info  Level.of(:info)
  @warn  Level.of(:warn)
  @error Level.of(:error)

  import IO.ANSI

  defstruct(
    format_string:  "$time [$level] $pad(22) $message",
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
    metadata_color:  italic() <> faint(),

    use_ansi_color?: true
  )


end
