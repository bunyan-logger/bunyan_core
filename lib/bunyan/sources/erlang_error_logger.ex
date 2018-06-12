defmodule Bunyan.Sources.ErlangErrorLogger do

  @behaviour :gen_event

  alias Bunyan.{ Collector, Level }

  def init(args) do
    {  :ok, args }
  end

  def handle_event(msg, state) do
    { :ok, error_log(msg, state) }
  end

  # gl === group_leader

  # Generated when error_msg/1,2 or format is called.
  def error_log({ :error, gl, { pid, format, data}}, state) do
  end

  # Generated when warning_msg/1,2 is called if warnings are set to be tagged as warnings.
  def error_log({ :warning_msg, gl, { pid, format, data }}, state) do
  end

  # Generated when info_msg/1,2 is called.
  def error_log({ :info_msg, gl, { pid, format, data }}, state) do
  end

  # reports are lists of  [{Tag :: term(), Data :: term()} | term()] | string() | term()

  # Generated when error_report/1 or /2 is called.
  def error_log({ :error_report, _gl, { pid, type, report }}, state) do
    report(:error, pid, type, report, state)
  end

  # Generated when warning_report/1 or /2 is called if warnings are set to be
  # tagged as warnings.
  def error_log({ :warning_report, _gl, { pid, type, report }}, state) do
    report(:warn, pid, type, report, state)
  end

  #  Generated when info_report/1 or /2 is called.
  def error_log({ :info_report, _gl, { pid, type, report }}, state) do
    report(:info, pid, type, report, state)
  end

  def error_log(event, state) do
    IO.inspect error_log: event
    { :ok, state }
  end

  def handle_call(arg, state) do
    IO.inspect handle_call: arg
    { :ok, nil, state }
  end


  def report(level, pid, type, report, state) do
    reporter = fn ->
      report = report ++ [ type: type, pid: pid ]
      report |> Enum.map(&inspect/1)
    end
    Collector.maybe_log({ Level.of(level), reporter, %{} })
    state
  end
end
