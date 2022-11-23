defmodule Client do
  use Application

  @tcp_client :tcp_client
  def start(_type, _args) do
    children = [
      {TcpClient, @tcp_client}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, type: :supervisor)
  end
end
