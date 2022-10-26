defmodule Rtp.Listener do
  @moduledoc """
  a process for listening the tweet1 and tweet2 feeds of the SSE Streaming API
  """
  use GenServer

  @restart_time 3000

  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def init(url) do
    IO.puts("listener #{inspect(self())} starts up on #{url}...")
    GenServer.cast(self(), :start_stream)

    {:ok, url}
  end

  @doc """
  processes incoming info and sends the main data to dispatcher process
  """
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, url) do
    [type, tweet] = Rtp.Utils.TweetParser.process(chunk)
    IO.inspect(type)
    IO.inspect(tweet)
    Process.sleep(2000)

    {:noreply, url}
  end

  def handle_info(%HTTPoison.AsyncStatus{} = status, url) do
    IO.puts("Connection status #{inspect(self())}: #{inspect(status)}")

    {:noreply, url}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = headers, url) do
    IO.puts("Connection headers #{inspect(self())}: #{inspect(headers)}")

    {:noreply, url}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, url) do
    IO.puts("Connection to the stream feed ends...")
    IO.puts("Starting new connection in #{@restart_time} ms")

    Process.sleep(@restart_time)
    GenServer.cast(:start_stream, url)
    IO.puts("Connection Established")

    {:noreply, url}
  end

  def handle_cast(:start_stream, url) do
    HTTPoison.get!(url, [],
      recv_timeout: 10_000,
      timeout: 10_000,
      stream_to: self(),
      hackney: [pool: :default]
    )

    {:noreply, url}
  end
end
