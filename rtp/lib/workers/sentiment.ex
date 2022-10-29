defmodule Rtp.Sentiment do
  use GenServer
  require GenServer

  @worker_idle 50..500
  @aggregator :aggregator

  def start_link(emotion_dict) do
    GenServer.start_link(__MODULE__, emotion_dict)
  end

  def init(emotion_dict) do
    {:ok, emotion_dict}
  end

  def emotional_val(word, emotion_dict) do
    cond do
      Map.has_key?(emotion_dict, word) -> String.to_integer(emotion_dict[word])
      true -> 0.0
    end
  end

  def handle_cast([:tweet, tweet], emotion_dict) do
    msg_arr = String.split(tweet.text)
    emotional_sum = Enum.reduce(msg_arr, 0, fn x, acc -> emotional_val(x, emotion_dict) + acc end)
    sentiment = emotional_sum / Enum.count(msg_arr)


    tweet = %{tweet | sentiment: sentiment}
    GenServer.cast(@aggregator, [:batch, tweet])

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:noreply, emotion_dict}
  end

  def handle_cast([:panic, tweet], emotion_dict) do
    IO.inspect("#{inspect(tweet)} -> #{inspect(self())}")

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:noreply, emotion_dict}
  end
end
