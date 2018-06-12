defmodule Bunyan.Kickoff do

  use GenServer


  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    Process.send_after(self(), :start_writers, 0)
    { :ok, options }
  end

  def handle_info(:start_writers, options) do
    Keyword.get(options, :write_to, [])
    |> Enum.each(&Bunyan.Writers.add_writer(&1))

    { :noreply, options }
  end
end
