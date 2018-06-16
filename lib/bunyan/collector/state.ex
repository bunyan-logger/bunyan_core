defmodule Bunyan.Collector.State do


  defstruct(
    minimum_level_to_report: :not_yet_set
  )


  def from(_options) do
    %__MODULE__{
      minimum_level_to_report: Bunyan.runtime_log_level_number()
    }
  end
end
