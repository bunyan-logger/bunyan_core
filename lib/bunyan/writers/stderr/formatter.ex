defmodule Bunyan.Writers.Stderr.Formatter do

  #

  @moduledoc """

  * `$date`     - date the log message was sent (yy-mm-dd)
  * `$time`     - time the log message was sent (hh:mm:ss.mmm)
  * `$datetime` - "$date $time"
  * `$message`  - whole log message
  * `$msg_first_line` - just the first line of the message
  * `$msg_rest` - lines 2... of the message
  * `$level`    - the log level
  * `$node`     - the node that prints the message
  * `$pid`      - the pid that generated the messae
  * `$metadata` - user controlled data presented in `"key=val key2=val2 "` format
  """

  @ansi_reset IO.ANSI.reset


  # stolen in part from Logger.Formatter
  @regex Regex.recompile!(~r/(?<head>)\$[a-z_]+(?:\(\d+\))?(?<tail>)/)

  def compile_format(main_format, extra_format) do

    main_format_fields = fields_in(main_format)

    main_message = Enum.map(main_format_fields, &field_builder/1)
    prefix_size  = prefix_size(main_format_fields)
    padding      = String.duplicate(" ", prefix_size)

    extra_message =
      fields_in(extra_format)
      |> Enum.map(&field_builder/1)


    preload = if main_format <> extra_format =~ ~r/\$(date|time)/ do
      quote do
        { utc_date, utc_time } = :calendar.now_to_universal_time(time)
      end
    else
      nil
    end

    quote do
      fn (level, msg, metadata, time, state) ->
        [ msg_first_line, msg_rest ] = String.split(msg, ~r/\n/, trim: true, parts: 2)
        unquote(preload)

        [
          unquote(main_message),
          unquote(__MODULE__).indent(unquote(extra_message), unquote(padding))
        ]
      end
    end
    |> Code.eval_quoted()
  end


  ##################################################################################

  defp field_builder("$date") do
    quote do
      [
        state.timestamp_color,
        unquote(__MODULE__).format_date(utc_date),
        unquote(@ansi_reset)
    ]
  end
  end

  defp field_builder("$time") do
    quote do
      [
        state.timestamp_color,
        unquote(__MODULE__).format_time(utc_time, time),
        unquote(@ansi_reset)
    ]
  end
  end

  defp field_builder("$datetime") do
    quote do
      [
        state.timestamp_color,
        "#{unquote(__MODULE__).format_date(utc_date)} #{unquote(__MODULE__).format_time(utc_time, time)}",
        unquote(@ansi_reset)
      ]
    end
  end



  defp field_builder("$message_first_line") do
    quote do
      [
        state.message_colors[level],
        msg_first_line,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$message_rest") do
    quote do
      [
        state.message_colors[level],
        msg_rest,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$message") do
    quote do
      [
        state.message_colors[level],
        msg,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$level") do
    quote do
      [
        state.level_colors[level],
        Bunyan.Level.to_s(level),
        unquote(@ansi_reset)
      ]
    end
  end
  defp field_builder("$node") do
    quote do
      inspect(node)
    end
  end
  defp field_builder("$pid") do
    quote do
      inspect(pid)
    end
  end

  defp field_builder("$metadata") do
    quote do
      [
        state.metadata_color,
        unquote(__MODULE__).format_metadata(metadata),
        unquote(@ansi_reset)
      ]
    end
  end


  defp field_builder("$" <> rest) do
    raise """

    Unknown Logger format field: $#{rest}

    Valid formats are:

      $date     - date the log message was sent (yy-mm-dd)
      $time     - time the log message was sent (hh:mm:ss.mmm)
      $datetime - "$date $time"
      $message  - the log message
      $level    - the log level
      $node     - the node that prints the message
      $pid      - the pid that generated the message
      $metadata - user controlled data presented in `"key=val key2=val2 "` format

    """
  end


  defp field_builder(text) do
    quote do
      unquote(text)
    end
  end


  ##################################################################################

  defp field_size("$message_first_line"), do: :stop
  defp field_size("$message_rest"),       do: :stop
  defp field_size("$message"),            do: :stop

  defp field_size("$date"),     do: 10
  defp field_size("$time"),     do: 12
  defp field_size("$datetime"), do: 23
  defp field_size("$level"),    do:  1

  defp field_size("$node"),     do: 15
  defp field_size("$pid"),      do: 12
  defp field_size("$metadata"), do:  0

  defp field_size(text) when is_binary(text), do: String.length(text)

  #####################################################################################


  defp fields_in(format) do
    IO.inspect fields_in: [ @regex, format ]
    Regex.split(@regex, format <> "\n", on: [:head, :tail], trim: true)
  end

  defp prefix_size(fields) do
    fields
    |> Enum.reduce_while(0, fn field, size ->
      case field_size(field)  do
        :stop ->
          { :halt, size }
        n ->
          { :cont, size + n }
      end
    end)
  end

  def format_metadata(nil), do: []

  def format_metadata(data) when is_map(data) do
    max_key_len= Map.keys(data) |> Enum.map(&inspect/1) |> Enum.map(&String.length/1) |> Enum.max
    key_len = min(max_key_len, 20)

    Enum.map(data, fn { key, value } ->
      "#{String.pad_trailing(inspect(key), key_len)} => #{inspect value}"
    end)
    |> Enum.join("\n")
  end

  def format_metadata(data) when is_list(data) do
      Enum.map(data, &format_list_element/1)
  end

  def format_metadata(data) do
      inspect(data)
  end

  defp format_list_element({ key, value }) do
    "#{inspect key} => #{inspect value}"
  end

  defp format_list_element(value) do
    inspect value
  end


  def format_date({y, m, d}) do
    "#{y}-#{pad2(m)}-#{pad2(d)}"
  end

  def format_time({ h, m, s }, { _, _, micros }) do
    "#{pad2(h)}:#{pad2(m)}:#{pad2(s)}.#{pad_millis(div(micros, 1000))}"
  end

  defp pad2(0), do: "00"
  defp pad2(1), do: "01"
  defp pad2(2), do: "02"
  defp pad2(3), do: "03"
  defp pad2(4), do: "04"
  defp pad2(5), do: "05"
  defp pad2(6), do: "06"
  defp pad2(7), do: "07"
  defp pad2(8), do: "08"
  defp pad2(9), do: "09"
  defp pad2(n), do: n

  defp pad_millis(n) when n < 10,   do: "00#{n}"
  defp pad_millis(n) when n < 100,  do: "0#{n}"
  defp pad_millis(n) when n < 1000, do: "#{n}"
  defp pad_millis(_), do: "***"

  def indent(extra, padding) do
    extra
    |> Enum.join("")
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn line -> [ padding, line, "\n" ] end)
  end
end
