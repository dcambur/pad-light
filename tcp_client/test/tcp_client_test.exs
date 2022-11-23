defmodule TcpClientTest do
  use ExUnit.Case
  doctest TcpClient

  test "greets the world" do
    assert TcpClient.hello() == :world
  end
end
