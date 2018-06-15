defmodule Bunyan.Source.ErlangErrorLogger.EventHandler do

  @behaviour :gen_event

  alias Bunyan.{ Collector, Level, LogMsg, Source.ErlangErrorLogger.Report }

  def init(args) do
    { :ok, args }
  end

  def handle_event(msg, state) do
    # IO.inspect ERROR: msg
    { :ok, error_log(msg, state) }
  end

  # gl === group_leader

  # Generated when error_msg/1,2 or format is called.
  def error_log({ :error, gl, { pid, format, data}}, state) do
    log(:error, gl, pid, format, data)
    { :ok, state }
  end

  # Generated when warning_msg/1,2 is called if warnings are set to be tagged as warnings.
  def error_log({ :warning_msg, gl, { pid, format, data }}, state) do
    log(:warn, gl, pid, format, data)
    { :ok, state }
  end

  # Generated when info_msg/1,2 is called.
  def error_log({ :info_msg, gl, { pid, format, data }}, state) do
    log(:info, gl, pid, format, data)
    { :ok, state }
  end

  # reports are lists of  [{Tag :: term(), Data :: term()} | term()] | string() | term()

  # Generated when error_report/1 or /2 is called.
  def error_log({ :error_report, _gl, { pid, type, report }}, state) do
    Report.report(:error, pid, type, report)
    { :ok, state }
  end

  # Generated when warning_report/1 or /2 is called if warnings are set to be
  # tagged as warnings.
  def error_log({ :warning_report, _gl, { pid, type, report }}, state) do
    Report.report(:warn, pid, type, report)
    { :ok, state }
  end

  #  Generated when info_report/1 or /2 is called.
  def error_log({ :info_report, _gl, { pid, type, report }}, state) do
    Report.report(:info, pid, type, report)
    { :ok, state }
  end

  def error_log(event, state) do
    IO.inspect error_log: event
    { :ok, state }
  end

  def handle_call(arg, state) do
    IO.inspect handle_call: arg
    { :ok, nil, state }
  end


  def log(level, _gl, pid, format, data) when is_list(data) do
    msg = :io_lib.format(format, data) |> List.flatten() |> List.to_string() |> String.trim_trailing()

    %LogMsg{
      level:     Level.of(level),
      msg:       msg,
      extra:     "(Erlang error report)",
      timestamp: :os.timestamp(),
      pid:       pid,
      node:      node(pid)
    } |> Collector.maybe_log()
  end

  def log(level, _gl, pid, format, data) do
    msg = """
    bad data for format in `:error_logger.#{level}_msg(#{inspect format}, #{inspect data}):
    list expected for 2nd parameter
    (Erlang error report)
    """

    %LogMsg{
      level:     Level.of(level),
      msg:       msg,
      timestamp: :os.timestamp(),
      pid:       pid,
      node:      node(pid)
    }
    |> Collector.maybe_log()
  end
end
