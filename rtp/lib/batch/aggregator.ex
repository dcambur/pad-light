defmodule Rtp.Aggregator do
  use GenServer
  alias Rtp.Utils.Tweet, as: Tweet

  @sink :sink

  @batch_size 1
  @timeframe 2000

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    Process.send_after(self(), :sink_send, @timeframe)
    {:ok, %{}}
  end

  def handle_cast([:batch, tweet], tweet_map) when not is_map_key(tweet_map, tweet.id) do
    tweet_map = Map.put(tweet_map, tweet.id, tweet)

    {:noreply, tweet_map}
  end

  def handle_cast([:batch, tweet], tweet_map) when is_map_key(tweet_map, tweet.id) do
    tweet = Tweet.set_sink_ready(tweet)
    # if tweet engagement isn't zero, then tweet_map stores sentiment
    # if tweet sentiment isn't zero, then tweet_map stores engagement
    # so we set tweet to contain both engagement and sentiment and update tweet_map
    # in other cases both of them are zero, there is no need to update tweet, just tweet_map
    tweet_map = update_map(tweet, tweet_map)

    to_sink = Map.filter(tweet_map, fn {_key, val} -> val.sink_ready == true end)
    ready_count = Enum.count(to_sink)

    left = sink_batch(tweet_map, to_sink, ready_count)

    {:noreply, left}
  end

  defp update_map(tweet, tweet_map) when tweet.engagement != 0 do
    tweet = Tweet.set_sentiment(tweet, tweet_map[tweet.id].engagement)
    tweet_map = Map.update!(tweet_map, tweet.id, &(&1 = tweet))
  end

  defp update_map(tweet, tweet_map) when tweet.sentiment != 0 do
    tweet = Tweet.set_engagement(tweet, tweet_map[tweet.id].engagement)
    tweet_map = Map.update!(tweet_map, tweet.id, &(&1 = tweet))
  end

  defp update_map(tweet, tweet_map) do
    tweet_map = Map.update!(tweet_map, tweet.id, &(&1 = tweet))
  end

  def handle_info(:sink_send, tweet_map) do
    to_sink = Map.filter(tweet_map, fn {_key, val} -> val.sink_ready == true end)
    ready_count = Enum.count(to_sink)

    IO.inspect("all tweets: #{Enum.count(tweet_map)}")
    IO.inspect("sink ready: #{ready_count}")
    IO.puts("-------------------------------------------------")

    left = sink_batch(tweet_map, to_sink, ready_count)


    Process.send_after(self(), :sink_send, @timeframe)

    {:noreply, left}
  end

  def sink_batch(tweet_map, batch, cur_size) when cur_size >= @batch_size do
    GenServer.call(@sink, [:batch_write, batch])

    Map.filter(tweet_map, fn {_key, val} -> val.sink_ready == false end)
  end

  def sink_batch(tweet_map, batch, cur_size) do
    tweet_map
  end
end
