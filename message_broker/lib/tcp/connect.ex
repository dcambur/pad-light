defmodule MBroker.Tcp.Connect do
  use GenServer
  require Logger

  @del " "
  @publish "PUB"
  @subscribe "SUB"
  @unsubscribe "UNSUB"
  @tcp_commands :tcp_commands

  def start(socket: socket) do
    GenServer.start(__MODULE__, socket: socket)
  end

  def init(socket: socket) do
    Logger.info("connection to #{inspect(socket)} is open")

    {:ok, socket}
  end

  def handle_info({:tcp, socket, data}, state) do

    data = :erlang.binary_to_term(data)
    cond do
      data.command == @publish -> GenServer.call(@tcp_commands, [:publish, socket, data])
      data.command == @subscribe -> GenServer.call(@tcp_commands, [:subscribe, socket, data])
      true -> IO.inspect("Error: Command is Incorrect")
    end

    :inet.setopts(socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    GenServer.call(@tcp_commands, [:unsubscribe, socket])
    Logger.info("connection to #{inspect(socket)} was closed")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, _}, state), do: {:ok, :normal, state}
end
