defmodule TcpClient do
  alias ElixirLS.LanguageServer.Providers.DocumentSymbols.Info
  alias Enumerable.GenEvent
  use GenServer

  @init_state %{socket: nil}
  @hostname 'localhost'
  @port 8000
  @topic_tweet "tweet"
  @sub_com "SUB"
  @unsub_com "UNSUB"
  @quit_com "q"

  def start_link(name) do
    GenServer.start_link(__MODULE__, @init_state, name: name)
  end

  def init(init_state) do
    opts = [:binary, active: true, packet: 4, send_timeout: :infinity]
    case :gen_tcp.connect(@hostname, @port, opts) do
      {:ok, socket} -> cmd_loop(%{init_state | socket: socket})
      {:error, reason} -> {:stop, :normal, init_state}
    end
    {:ok, nil}
  end

  def cmd_loop(%{socket: socket} = state) do
    IO.write("Enter a command (SUB TOPIC_NAME): ")
    parsed = IO.read(:stdio, :line)
    |> String.trim("\n")
    |> String.split(" ")

    if (List.first(parsed) == @sub_com) do
      subscribe_control(socket, List.last(parsed))
    end

    if (List.first(parsed) == @quit_com) do
      System.stop(0)
    end

  end

  def subscribe_control(socket, topic) do
    to_sent = :erlang.term_to_binary(%{topic: topic, command: @sub_com})
    status = :gen_tcp.send(socket, to_sent)
    IO.inspect("subscribed to #{inspect(socket)} on #{inspect(topic)} topic")

    :gen_tcp.controlling_process(socket, self())

  end

  def handle_info({:tcp, socket, data}, _) do
    :erlang.binary_to_term(data)
    |> IO.inspect()
    {:noreply, nil}
  end

end
