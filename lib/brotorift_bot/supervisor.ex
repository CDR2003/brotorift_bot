defmodule BrotoriftBot.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {BrotoriftBot.ReportSupervisor, []},
      {BrotoriftBot.ReportManager, []},
      {BrotoriftBot.TcpReceiverSupervisor, []},
      {BrotoriftBot.TcpClientSupervisor, []},
      {Task.Supervisor, name: BrotoriftBot.BotSupervisor},
      {DynamicSupervisor, name: BrotoriftBot.ClientSupervisor, strategy: :one_for_one},
      {BrotoriftBot.BotManager, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
