defmodule Rtp.Aggregator do
  use GenServer
  alias Rtp.Utils.Tweet, as: Tweet

  @sink :sink

  @batch_size 32
  @timeframe 2000

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    Process.send_after(self(), :sink_send, @timeframe)
    {:ok, %{}}
  end

  def handle_call([:batch, tweet], _from, tweet_map) when not is_map_key(tweet_map, tweet.id) do

    tweet_map = Map.put(tweet_map, tweet.id, tweet)

    {:reply, :ok, tweet_map}
  end

  def handle_call([:batch, tweet], _from, tweet_map) when is_map_key(tweet_map, tweet.id) do
    tweet = Tweet.set_sink_ready(tweet)
    tweet_map = Map.update!(tweet_map, tweet.id, &(&1 = tweet))

    {:reply, :ok, tweet_map}
  end

  def handle_info(:sink_send, tweet_map) do
    cur_size = Enum.count(tweet_map)
    IO.inspect(cur_size)

    left = sink_batch(tweet_map, cur_size)

    Process.send_after(self(), :sink_send, @timeframe)

    {:noreply, left}
  end

  def sink_batch(batch, cur_size) when cur_size >= @batch_size do
    to_sink = Map.filter(batch, fn {_key, val} -> val.sink_ready == true end)
    GenServer.call(@sink, [:batch_write, batch])

    Map.filter(batch, fn {_key, val} -> val.sink_ready == false end)
  end

  def sink_batch(batch, cur_size) do
    batch
  end
end
