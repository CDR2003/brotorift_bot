defmodule PingPongServer.Bots do
  def bot1(client) do
    PingPongServer.Client.connect(client)

    PingPongServer.Client.send_ping(client)
    PingPongServer.Client.receive_pong(client)

    PingPongServer.Client.send_ping(client)
    PingPongServer.Client.receive_pong(client)
  end
end
