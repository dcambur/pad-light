defmodule MBroker.Tcp.Commands do
  alias ElixirLS.LanguageServer.Providers.DocumentSymbols.Info
  require Logger
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_call([:subscribe, socket, data], _from, subs) when is_map_key(subs, data.topic) do
    {status, cur_socks} = Map.fetch(subs, data.topic)
    new_socks = cur_socks ++ [socket]

    subs = Map.replace(subs, data.topic, new_socks)
    Logger.info("#{inspect(socket)} was subscribed to #{inspect(data.topic)}")
    Logger.info("current subscriptions: #{inspect(subs)}")
    {:reply, :ok, subs}
  end

  def handle_call([:subscribe, socket, data], _from, subs) do
    subs = Map.put_new(subs, data.topic, [socket])
    Logger.info("#{inspect(socket)} was subscribed to #{inspect(data.topic)}")
    Logger.info("current subscriptions: #{inspect(subs)}")
    {:reply, :ok, subs}
  end

  def handle_call([:unsubscribe, socket], _from, subs) do
    {topic, sub_socks} = Enum.find(subs, fn {key, value} -> socket in value end)

    new_socks = List.delete(sub_socks, socket)

    subs = Map.replace(subs, topic, new_socks)
    Logger.info("#{inspect(socket)} was unsubscribed from #{inspect(topic)}")
    Logger.info("current subscriptions: #{inspect(subs)}")

    {:reply, :ok, subs}
  end

  def handle_call([:publish, socket, data], _from, subs) do
    {status, sub_socks} = Map.fetch(subs, data.topic)
    data = :erlang.term_to_binary(%{topic: data.topic, data: data.data})

    Enum.each(sub_socks, fn sub_sock -> :gen_tcp.send(sub_sock, data) end)
    {:reply, :ok, subs}
  end
end
