defmodule Rtp.Utils.TweetParser do
  @moduledoc """
  utility module for processing SSE strings into
  key-value data structure in Elixir
  """
  alias Rtp.Utils.Tweet, as: Tweet

  @event_ok "event: \"message\"\n\ndata: "
  @event_panic "event: \"message\"\n\ndata: {\"message\": panic}\n\n"
  @panic_msg %{error: "Panic! Worker terminates forcefully."}

  @message "message"
  @tweet "tweet"
  @retweeted_status "retweeted_status"
  @user "user"
  @doc """
  handles convertation to key-value structure
  """
  def process(raw_msg) do
    cond do
      String.contains?(raw_msg, @event_panic) ->
        give_panic()

      String.contains?(raw_msg, @event_ok) ->
        raw_msg
        |> sse_to_dict()
        |> give_message()

      true ->
        [nil, nil]
    end
  end

  defp sse_to_dict(string) do
    String.split(string, @event_ok)
    |> Poison.decode!()
  end

  defp give_message(message) do
    case message[@message][@tweet][@retweeted_status] do
      nil -> give_tweet(message)
      _ -> give_retweet(message)
    end
  end

  defp give_tweet(message) do
    [
      :tweet,
      %Tweet{
        id: String.to_atom(message[@message][@tweet]["id_str"]),
        created_at: message[@message][@tweet]["created_at"],
        text: message[@message][@tweet]["text"],
        username: message[@message][@tweet][@user]["name"],
        followers_count: message[@message][@tweet][@user]["followers_count"],
        retweet_count: message[@message][@tweet]["retweet_count"],
        favorite_count: message[@message][@tweet]["favorite_count"],
        from_retweet: false,
        sink_ready: false,
        sentiment: 0,
        engagement: 0
      }
    ]
  end

  defp give_retweet(message) do
    [
      :tweet,
      %Tweet{
        id: String.to_atom(message[@message][@tweet][@retweeted_status]["id_str"]),
        created_at: message[@message][@tweet][@retweeted_status]["created_at"],
        text: message[@message][@tweet][@retweeted_status]["text"],
        username: message[@message][@tweet][@retweeted_status][@user]["name"],
        followers_count: message[@message][@tweet][@retweeted_status][@user]["followers_count"],
        retweet_count: message[@message][@tweet][@retweeted_status]["retweet_count"],
        favorite_count: message[@message][@tweet][@retweeted_status]["favorite_count"],
        from_retweet: true,
        sink_ready: false,
        sentiment: 0,
        engagement: 0
      }
    ]
  end

  defp give_panic() do
    [:panic, @panic_msg]
  end
end
