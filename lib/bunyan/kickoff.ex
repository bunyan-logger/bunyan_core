defmodule Bunyan.Kickoff do

  use GenServer


  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(config) do
    Process.send_after(self(), :kickoff, 0)
    { :ok, config }
  end

  def handle_info(:kickoff, config) do
    start_writers(config)
    start_sources(config)

    { :noreply, config }
  end

  defp start_writers(config) do
    Keyword.get(config, :write_to, [])
    |> Bunyan.Writer.load_all_from_config()
  end

  defp start_sources(config) do
    Keyword.get(config, :read_from, [])
    |> Bunyan.Source.load_all_from_config()
  end

end
