defmodule MBroker.Super do
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
      {MBroker.Tcp.Server, @tcp_server}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
