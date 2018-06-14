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
  * `$extra`    - any term. maps and keyword lists are formatted nicely
  """

  @ansi_reset IO.ANSI.reset


  # stolen in part from Logger.Formatter
  @regex Regex.recompile!(~r/(?<head>)\$[a-z_]+(?:\(\d+\))?(?<tail>)/)

  # this is all compile time, so we try to do as much work here as
  # we can.

  def compile_format(main_format, extra_format, options) do

    is_color?    = !!options.use_ansi_color?

    main_format_fields = fields_in(main_format)

    main_message = Enum.map(main_format_fields, &field_builder(&1, is_color?, options))
    prefix_size  = prefix_size(main_format_fields)
    padding      = String.duplicate(" ", prefix_size)


    extra_message =
      fields_in(extra_format)
      |> Enum.map(&field_builder(&1, is_color?, options))


    preload = if main_format <> extra_format =~ ~r/\$(date|time)/ do
      quote do
        { utc_date, utc_time } = :calendar.now_to_universal_time(timestamp)
      end
    else
      nil
    end

    quote do
      fn (%Bunyan.LogMsg{
                   level:     level,
                   msg:       msg,
                   extra:     extra,
                   timestamp: timestamp,
                   pid:       pid,
                   node:      node
                 }
      ) ->

        { msg_first_line, msg_rest } = case String.split(msg, ~r/\n/, trim: true, parts: 2) do
          [] ->
            { "", [] }
          [ first | rest ] ->
            { first, rest }
        end

        unquote(preload)

        [
          unquote(main_message),
          unquote(__MODULE__).indent(unquote(extra_message), unquote(padding))
        ]
      end
    end
    |> Code.eval_quoted()
    |> elem(0)
  end


  ##################################################################################

  defp field_builder("$date", _ansi = true, options) do
    quote do
      [
        unquote(options.timestamp_color),
        unquote(__MODULE__).format_date(utc_date),
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$date", _ansi = false, _) do
    quote do
      unquote(__MODULE__).format_date(utc_date)
    end
  end



  defp field_builder("$time", _ansi = true, options) do
    quote do
      [
        unquote(options.timestamp_color),
        unquote(__MODULE__).format_time(utc_time, timestamp),
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$time", _ansi = false, _) do
    quote do
      unquote(__MODULE__).format_time(utc_time, timestamp)
    end
  end




  defp field_builder("$datetime", _ansi = true, options) do
    quote do
      [
        unquote(options.timestamp_color),
        "#{unquote(__MODULE__).format_date(utc_date)} #{unquote(__MODULE__).format_time(utc_time, timestamp)}",
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$datetime", _ansi = false, _) do
    quote do
      "#{unquote(__MODULE__).format_date(utc_date)} #{unquote(__MODULE__).format_time(utc_time, timestamp)}"
    end
  end





  defp field_builder("$message_first_line", _ansi = true, options) do
    quote do
      [
        unquote(Macro.escape(options.message_colors))[level],
        msg_first_line,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$message_first_line", _ansi = false, _) do
    quote do
      msg_first_line
    end
  end



  defp field_builder("$message_rest", _ansi = true, options) do
    quote do
      [
        unquote(Macro.escape(options.message_colors))[level],
        msg_rest,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$message_rest", _ansi = false, _) do
    quote do
      msg_rest
    end
  end



  defp field_builder("$message", _ansi = true, options) do
    quote do
      [
        unquote(Macro.escape(options.message_colors))[level],
        msg,
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$message", _ansi = false, _) do
    quote do
      msg
    end
  end


  defp field_builder("$level", _ansi = true, options) do
    quote do
      [
        unquote(Macro.escape(options.level_colors))[level],
        Bunyan.Level.to_s(level),
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$level", _ansi = false, _) do
    quote do
      Bunyan.Level.to_s(level)
    end
  end



  defp field_builder("$node", _, _) do
    quote do
      inspect(node)
    end
  end

  defp field_builder("$pid", _, _) do
    quote do
      inspect(pid)
    end
  end

  defp field_builder("$extra", _ansi = true, options) do
    quote do
      [
        unquote(options.extra_color),
        unquote(__MODULE__).format_extra(extra),
        unquote(@ansi_reset)
      ]
    end
  end

  defp field_builder("$extra", _ansi = false, _) do
    quote do
      unquote(__MODULE__).format_extra(extra)
    end
  end



  defp field_builder("$" <> rest, _, _) do
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
      $extra    - any term. maps and keyword lists are formatted nicely

    """
  end


  defp field_builder(text, _, _) do
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
  defp field_size("$extra"),    do:  0

  defp field_size(text) when is_binary(text), do: String.length(text)

  #####################################################################################


  defp fields_in(format) do
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

  def format_extra(nil), do: []

  def format_extra(data) when is_map(data) do
    max_key_len= Map.keys(data) |> Enum.map(&inspect/1) |> Enum.map(&String.length/1) |> Enum.max
    key_len = min(max_key_len, 20)

    Enum.map(data, fn { key, value } ->
      "#{String.pad_trailing(inspect(key), key_len)} => #{inspect value}"
    end)
    |> Enum.join("\n")
  end

  def format_extra(data) when is_list(data) do
      Enum.map(data, &format_list_element/1)
  end

  def format_extra(data) do
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
