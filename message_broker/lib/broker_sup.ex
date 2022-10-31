defmodule MBroker.Super do
  @moduledoc """
  module created to run all children supervisors,
  Essentially, it is a main supervisor.
  """

  use Supervisor
  @tcp_server :tcp_server
  @doc """
  runs the main supervisor
  """
  def start_link([]) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts("main supervisor starts up...")

    children = [
      Supervisor.child_spec({MBroker.Tcp.Server, 8000}, id: @tcp_server)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
