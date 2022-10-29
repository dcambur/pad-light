defmodule Rtp.Super do
  @moduledoc """
  module created to run all children supervisors,
  Essentially, it is a main supervisor.
  """

  use Supervisor

  @tweet1 "http://127.0.0.1:4000/tweets/1"
  @tweet2 "http://127.0.0.1:4000/tweets/2"
  @emotion_url "http://localhost:4000/emotion_values"

  @listener_sup :listener_sup

  @engagement_type :engagement
  @sentiment_type :sentiment

  @aggregator :aggregator
  @sink :sink

  @doc """
  runs the main supervisor
  """
  def start_link([]) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts("main supervisor starts up...")
    emotion_dict = HTTPoison.get!(@emotion_url).body |> Rtp.Utils.EmotionParser.process()

    children = [
      Supervisor.child_spec({Rtp.Listener.Super, [@tweet1, @tweet2]}, id: @listener_sup),
      Supervisor.child_spec({Rtp.Aggregator, @aggregator}, id: @aggregator),
      Supervisor.child_spec({Rtp.Sink, @sink}, id: @sink),
      :poolboy.child_spec(@engagement_type, e_poolboy_config()),
      :poolboy.child_spec(@sentiment_type, s_poolboy_config(), emotion_dict)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp e_poolboy_config() do
    [
      name: {:local, @engagement_type},
      worker_module: Rtp.Engagement,
      size: 15,
      max_overflow: 0,
      strategy: :fifo

    ]
  end

  defp s_poolboy_config() do
    [
      name: {:local, @sentiment_type},
      worker_module: Rtp.Sentiment,
      size: 15,
      max_overflow: 0,
      strategy: :fifo
    ]
  end
end
