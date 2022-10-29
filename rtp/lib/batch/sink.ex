defmodule Rtp.Sink do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, nil}
  end

  def handle_call([:batch_write, batch], _from, _state) do
    #IO.inspect(batch)
    {:reply, :ok, nil}
  end
end
