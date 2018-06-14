defmodule Bunyan.LogMsg do

  defstruct(
    level:     0,
    msg:       "",
    extra:     nil,
    timestamp: nil,
    pid:       nil,
    node:      nil
  )
end
