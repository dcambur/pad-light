defmodule Rtp do
  use Application

  def start(_type, _args) do
    children = [
      Rtp.Super
    ]

    Supervisor.start_link(children, strategy: :one_for_one, type: :supervisor)
  end
end
