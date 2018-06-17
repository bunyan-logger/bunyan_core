
defmodule Bunyan.Level do

  @type t :: ( :debug | :info | :warn | :error )

  @compile { :inline,
        debug:   0,
        info:    0,
        warn:    0,
        error:   0,
        of:      1,
        to_s:    1,
        to_atom: 1
  }

  def debug, do: 00
  def info,  do: 10
  def warn,  do: 20
  def error, do: 30

  def of(:debug), do: debug()
  def of(:info),  do: info()
  def of(:warn),  do: warn()
  def of(:error), do: error()

  def of(other) do
    raise """

    Invalid log level (#{inspect other}).

    Valid levels are: :debug, :info, :warn, and :error

    """
  end

  def to_s(00), do: "D"
  def to_s(10), do: "I"
  def to_s(20), do: "W"
  def to_s(30), do: "E"
  def to_s(_),  do: "?"

  def to_atom(00), do: :debug
  def to_atom(10), do: :info
  def to_atom(20), do: :warn
  def to_atom(30), do: :error
end
