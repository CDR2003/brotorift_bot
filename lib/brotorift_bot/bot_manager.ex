defmodule BrotoriftBot.BotManager do
  use Task

  def start_link(_args) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    {:ok, bot_configs} = Application.fetch_env(:brotorift_bot, :bots)
    bot_configs_with_indices = bot_configs |> Enum.map(fn {fun, count} -> List.duplicate(fun, count) end) |> List.flatten()
    bots = bot_configs_with_indices |> Stream.with_index() |> Enum.map(&start_bot/1) |> Enum.to_list()

    wait_for_bots(bots)
  end

  def wait_for_bots(bots) do
    Enum.each(bots, fn bot -> Task.await(bot, :infinity) end)
    BrotoriftBot.ReportManager.generate_reports()
    {:noreply, bots}
  end

  defp start_bot({fun, index}) do
    {:ok, client_module} = Application.fetch_env(:brotorift_bot, :client)
    {:ok, client} = DynamicSupervisor.start_child(BrotoriftBot.ClientSupervisor, {client_module, []})
    Task.Supervisor.async(BrotoriftBot.BotSupervisor, fn -> fun.(client, index) end)
  end
end
