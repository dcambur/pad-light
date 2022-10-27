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
end
