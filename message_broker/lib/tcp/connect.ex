defmodule MBroker.Tcp.Connect do
  use GenServer
  require Logger


  def init([socket: socket]) do
    Logger.info("connection #{inspect(socket)} opens")

    serve(socket)

    {:ok, socket}
  end

  def handle_info({:tcp, socket, data}, state) do
    Logger.info("data received?")

    :inet.setopts(socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state) do
    Logger.info("closed connection")

    {:noreply, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    Logger.info("error")

    {:noreply, state}
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line(socket)

    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end

end
