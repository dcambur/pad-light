defmodule MBroker.Super do
  use Supervisor
  @tcp_server :tcp_server
  @tcp_commands :tcp_commands

  @doc """
  runs the main supervisor
  """
  def start_link([]) do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    IO.puts("main supervisor starts up...")

    children = [
      Supervisor.child_spec({MBroker.Tcp.Commands, @tcp_commands}, id: @tcp_commands),
      {MBroker.Tcp.Server, @tcp_server}

    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
