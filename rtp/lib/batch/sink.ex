defmodule Rtp.Sink do
  use GenServer

  @init_state %{socket: nil}
  @hostname 'localhost'
  @port 8000
  @topic_tweet "tweet"
  @publish "PUB"

  def start_link(name) do
    GenServer.start_link(__MODULE__, @init_state, name: name)
  end

  def init(init_state) do
    opts = [:binary, active: false, packet: 4, send_timeout: :infinity]
    case :gen_tcp.connect(@hostname, @port, opts) do
      {:ok, socket} -> {:ok, %{init_state | socket: socket}}
      {:error, reason} -> {:stop, :normal, init_state}
    end
  end

  def handle_call([:batch_write, batch], _from, %{socket: socket} = state) do
    to_send = :erlang.term_to_binary(%{topic: @topic_tweet, command: @publish, data: batch})
    :gen_tcp.send(socket, to_send)

    {:reply, :ok, state}
  end
end
