use Mix.Config

config :brotorift_bot,
  client: PingPongServer.Client,
  bots: [
    {&PingPongServer.Bots.bot1/1, 3}
  ],
  host: {127, 0, 0, 1},
  port: 12345,
  data_head: 123456,
  heartbeat_interval: 3000
