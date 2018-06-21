defmodule Bunyan.Writers.Remote.State do

  defstruct(
    target_process_name: nil,
    target_process_pid:  nil,
    min_log_level:       Bunyan.Shared.Level.of(:warn),
    timer_ref:           nil,
    pending:             [],
    max_pending_size:    100,
    max_pending_wait:    200   # milliseconds
  )
end
