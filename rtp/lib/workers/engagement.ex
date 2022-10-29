defmodule Rtp.Engagement do
  use GenServer
  require GenServer

  @worker_idle 50..500
  @aggregator :aggregator

  defp calculate_engagement(favorites, retweets, followers) when followers != 0 do
    (favorites + retweets) / followers
  end

  defp calculate_engagement(favorites, retweets, followers) when followers == 0 do
    0.0
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_cast([:tweet, tweet], _state) do
    engagement =
      calculate_engagement(
        tweet.favorite_count,
        tweet.retweet_count,
        tweet.followers_count
      )

    tweet = %{tweet | engagement: engagement}
    GenServer.cast(@aggregator, [:batch, tweet])

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:noreply, _state}
  end

  def handle_cast([:panic, tweet], _state) do
    IO.inspect("#{inspect(tweet)} -> #{inspect(self())}")

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:noreply, _state}
  end
end
