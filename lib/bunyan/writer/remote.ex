defmodule Bunyan.Writers.Remote do

  alias Bunyan.Writers.Remote.Server

  defdelegate child_spec(arg), to: Server

  def spray(msg, hosts) do
    for host <- hosts do
      GenServer.cast(host, { :send, msg })
    end
  end
end
