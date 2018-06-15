defmodule Bunyan.Kickoff do

  use GenServer


  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def init(options) do
    Process.send_after(self(), :kickoff, 0)
    { :ok, options }
  end

  def handle_info(:kickoff, options) do
    start_writers(options)
    start_sources(options)

    { :noreply, options }
  end

  defp start_writers(options) do
    Keyword.get(options, :write_to, [])
    |> Bunyan.Writer.load_all_from_config()
  end

  defp start_sources(options) do
    Keyword.get(options, :read_from, [])
    |> Bunyan.Source.load_all_from_config()
  end

end
