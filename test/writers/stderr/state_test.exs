defmodule Test.Bunyan.Writers.Stderr.State do

  use ExUnit.Case

  alias Bunyan.Level
  alias Bunyan.Writers.Stderr.{ State }

  @debug Level.of(:debug)
  @info  Level.of(:info)
  @warn  Level.of(:warn)
  @error Level.of(:error)

  test "Creating a state with no options leaves it unchanged apart from a format function" do
    result = State.from_options([])

    assert is_function(result.format_function)
    assert %{ result | format_function: nil } == %State{}
  end

  test "Set the format strings updates the format function appropriately" do
    result = State.from_options(main_format_string: "main", additional_format_string: "additional")

    assert result.main_format_string == "main"
    assert result.additional_format_string == "additional"

    output = result.format_function.(Test.Bunyan.Writers.Stderr.Formatter.msg(""))

    assert output |> IO.iodata_to_binary() == "main\n     additional\n"
 end

 test "top-level colors set" do
  result = State.from_options(
    timestamp_color: "time",
    extra_color:     "extra",
    use_ansi_color?: false
  )

  assert result.timestamp_color == "time"
  assert result.extra_color     == "extra"
  assert result.use_ansi_color? == false
 end

 test "level dependent colors set only if in options" do
  original = %State{}
  result = State.from_options(
    level_colors: [
      debug: "debug",
      error: "error"
    ],
    message_colors: [
      info:  "info",
      warn:  "warn",
    ]
  )

  assert result.level_colors[@debug] == "debug"
  assert result.level_colors[@info]  == original.level_colors[@info]
  assert result.level_colors[@warn]  == original.level_colors[@warn]
  assert result.level_colors[@error] == "error"

  assert result.message_colors[@debug] == original.level_colors[@debug]
  assert result.message_colors[@info]  == "info"
  assert result.message_colors[@warn]  == "warn"
  assert result.message_colors[@error] == original.level_colors[@error]
end
end
