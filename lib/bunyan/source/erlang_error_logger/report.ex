defmodule Bunyan.Source.ErlangErrorLogger.Report do


  alias Bunyan.{ Collector, Shared.Level, Shared.LogMsg }

  # SASL special cases

  ### Progress
  def report(level, pid, :progress, info = [
       supervisor: supervisor,
       started: rest
     ])
  do
    msg = "#{rest[:child_type]} #{format_module(rest[:id])} started by #{format_supervisor(supervisor)} as #{inspect rest[:pid]}"
    log(level, pid, msg, info)
  end

  def report(level, pid, :progress, info = [ application: app, started_at: node ]) do
    log(level, pid, "Application #{app} started #{format_node(node)}", info)
  end


  ### Crash report

  def report(level, pid, :crash_report, [info, _])  do
    IO.inspect crash: info
    msg = """
    #{format_initial_call(info[:error_info], info[:initial_call])}
    #{format_error_info(info[:error_info])}
    """
    log(level, pid, msg, info)
  end


  ### Supervisor report
  def report(level, pid, :supervisor_report, info) do
    msg = """
    #{format_supervisor(info[:supervisor])}: «#{info[:errorContext]}»  #{format_cause(info[:reason])}
    #{format_offender(info[:offender])}
    """
    log(level, pid, msg, info)
  end


  def report(level, pid, type, report) do
    #IO.inspect report: { level, pid, type, report }
    log(level, pid, inspect(type), [ wibble: report ])
  end


  defp log(level, pid, msg, extra) do
    %LogMsg{
      level:     Level.of(level),
      msg:       msg,
      extra:     extra,
      timestamp: :os.timestamp(),
      pid:       pid,
      node:      node(pid)
    } |> Collector.report()
  end


  defp format_initial_call({ type, _, _}, { m, f, a_list }) do
    "#{type} in #{m}.#{f}/#{length a_list}"
  end

  defp format_supervisor({ _pid, name }), do: format_module(name)
  defp format_supervisor(pid),            do: inspect(pid)

  defp format_error_info(nil), do: "no error info available"

  defp format_error_info({ _, cause, backtrace }) do

    """
    #{format_cause(cause)}
    #{format_backtrace(backtrace)}
   """
  end

  defp format_error_info(info) do
    inspect(info, pretty: true)
  end

  defp format_cause({ :bad_return_value, value }) do
    "Bad return value: #{inspect value}"
  end

  defp format_cause(other) do
    inspect(other, pretty: true)
  end

  defp format_backtrace(nil) do
    ""
  end


  defp format_backtrace(list) do
    list
    |> Enum.reduce({[], "from:  "}, &format_backtrace_line/2)
    |> elem(0)
    |> Enum.reverse
    |> Enum.join("\n")
  end

  defp format_backtrace_line({ m, f, a, place }, { result, prefix }) do
    line = "#{prefix}#{format_module(m)}.#{f}/#{a}\t(#{place[:file]}:#{place[:line]})"
    { [ line | result ], "        " }
  end

  defp format_offender(offender) do
    { m, f, a } = offender[:mfargs]
    """
    call: #{format_module(m)}.#{f}(#{a |> Enum.map(&inspect/1) |> Enum.join(", ")})
    """
  end

  defp format_module(m) when is_atom(m), do: format_module(to_string(m))

  defp format_module("Elixir." <> module), do: module
  defp format_module(module),              do: ":#{module}"

  defp format_node(:"nonode@nohost"), do: "locally"
  defp format_node(node),             do: "on node #{node}"

end
