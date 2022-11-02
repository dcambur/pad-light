defmodule MBroker.Tcp.Connect do
  use GenServer
  require Logger

  def start(socket: socket) do
    GenServer.start(__MODULE__, socket: socket)
  end

  def init(socket: socket) do
    Logger.info("connection #{inspect(socket)} opens")
    {:ok, socket}
  end

  def handle_info({:tcp, socket, data}, state) do
    Logger.info("Received #{data}")


    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state), do: {:stop, :normal, state}
  def handle_info({:tcp_error, _}, state), do: {:stop, :normal, state}

end
