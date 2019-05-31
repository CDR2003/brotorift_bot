defmodule BrotoriftBot.TcpReceiverSupervisor do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def create_receiver(report, protocol, socket) do
    DynamicSupervisor.start_child(__MODULE__, {BrotoriftBot.TcpReceiver, {report, protocol, socket}})
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
