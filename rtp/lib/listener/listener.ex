defmodule Rtp.Listener do
  @moduledoc """
  a process for listening the tweet1 and tweet2 feeds of the SSE Streaming API
  """
  use GenServer

  @restart_time 3000
  @engagement_type :engagement
  @sentiment_type :sentiment
  @panic :panic
  def start_link(url) do
    GenServer.start_link(__MODULE__, url)
  end

  def init(url) do
    IO.puts("listener #{inspect(self())} starts up on #{url}...")
    GenServer.cast(self(), :start_stream)

    {:ok, url}
  end

  @doc """
  processes incoming info and sends it to workers from poolboy
  """
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, url) do
    [type, tweet] = Rtp.Utils.TweetParser.process(chunk)

    engagement_pid = :poolboy.checkout(@engagement_type)
    sentiment_pid = :poolboy.checkout(@sentiment_type)

    GenServer.cast(engagement_pid, [type, tweet])
    GenServer.cast(sentiment_pid, [type, tweet])

    # will synchroniously stop poolboy workers
    # in case of panic message
    if type == @panic do
      GenServer.stop(engagement_pid)
      GenServer.stop(sentiment_pid)
    end

    # scaling still needs to be done even in case of panic
    :poolboy.checkin(@engagement_type, engagement_pid)
    :poolboy.checkin(@sentiment_type, sentiment_pid)

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
