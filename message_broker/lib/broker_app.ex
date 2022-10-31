defmodule MBroker do
  use Application

  def start(_type, _args) do
    children = [
      MBroker.Super
    ]

    Supervisor.start_link(children, strategy: :one_for_one, type: :supervisor)
  end
end
