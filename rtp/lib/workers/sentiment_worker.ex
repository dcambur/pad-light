defmodule Rtp.Sentiment do
  use GenServer

  @worker_idle 50..500

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call([:tweet, tweet], _from,  _state) do
    IO.inspect(tweet)

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:reply, :ok, _state}
  end

  def handle_call([:panic, tweet], _from,  _state) do
    IO.inspect("#{inspect(tweet)} -> #{inspect(self())}")

    Enum.random(@worker_idle)
    |> Process.sleep()

    {:reply, :ok, _state}
  end
end
