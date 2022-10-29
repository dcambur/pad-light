defmodule Rtp.Utils.Tweet do
  @enforce_keys [
    :id,
    :created_at,
    :text,
    :username,
    :retweet_count,
    :favorite_count,
    :followers_count,
    :from_retweet,
    :sink_ready,
    :sentiment,
    :engagement
  ]
  defstruct [
    :id,
    :created_at,
    :text,
    :username,
    :retweet_count,
    :favorite_count,
    :followers_count,
    :from_retweet,
    :sink_ready,
    :sentiment,
    :engagement
  ]

  def set_sink_ready(tweet) do
    tweet |> struct(%{sink_ready: true})
  end

  def set_sentiment(tweet, sentiment) do
    tweet |> struct(%{sentiment: sentiment})
  end

  def set_engagement(tweet, engagement) do
    tweet |> struct(%{engagement: engagement})
  end
end
