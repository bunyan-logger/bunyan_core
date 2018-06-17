defmodule Bunyan.Collector.State do


  # at some point we'll need collector options, and writing this makes
  # it parallel to the other genservers
  def from(_options) do
    %{}
  end
end
