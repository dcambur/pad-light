defmodule MBroker.Tcp.Server do
  use GenServer
  require Logger
  @port 8000

  def start_link(name) do
    GenServer.start_link(__MODULE__, @port, name: name)
  end

  def init(port) do
    {:ok, socket} =
    :gen_tcp.listen(port, [ :binary, packet: 4, active: :once, reuseaddr: true])

    Logger.info("Accepting connections on port #{port}")

    accept(socket)
    {:ok, port}
  end

  def accept(socket) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        {:ok, pid} = GenServer.start(MBroker.Tcp.Connect, socket: client_socket)
        :gen_tcp.controlling_process(client_socket, pid)
      {:error, reason} -> {:stop, :normal, socket}
    end
    accept(socket)
  end
end
