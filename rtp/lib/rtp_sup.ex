defmodule Rtp.Super do
  @moduledoc """
  module created to run all children supervisors,
  Essentially, it is a main supervisor.
  """

  use Supervisor

  @tweet1 "http://127.0.0.1:4000/tweets/1"
  @tweet2 "http://127.0.0.1:4000/tweets/2"

  @listener_sup :listener_sup

  @doc """
  runs the main supervisor
  """
  def start_link([]) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts("main supervisor starts up...")

    children = [
      Supervisor.child_spec({Rtp.Listener.Super, [@tweet1, @tweet2]}, id: @listener_sup),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
