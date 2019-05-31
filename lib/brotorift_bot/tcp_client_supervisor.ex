defmodule BrotoriftBot.TcpClientSupervisor do
  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def create_client(report, protocol) do
    DynamicSupervisor.start_child(__MODULE__, {BrotoriftBot.TcpClient, {report, protocol}})
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
