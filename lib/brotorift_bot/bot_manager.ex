defmodule BrotoriftBot.BotManager do
  use Task

  def start_link(_args) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    {:ok, bot_configs} = Application.fetch_env(:brotorift_bot, :bots)
    bots = bot_configs |> Enum.map(&start_bots/1) |> List.flatten()

    wait_for_bots(bots)
  end

  def wait_for_bots(bots) do
    Enum.each(bots, fn bot -> Task.await(bot, :infinity) end)
    BrotoriftBot.ReportManager.generate_reports()
    {:noreply, bots}
  end

  defp start_bots({fun, count}) do
    (1 .. count) |> Enum.map(fn _i ->
      {:ok, client_module} = Application.fetch_env(:brotorift_bot, :client)
      {:ok, client} = DynamicSupervisor.start_child(BrotoriftBot.ClientSupervisor, {client_module, []})
      Task.Supervisor.async(BrotoriftBot.BotSupervisor, fn -> fun.(client) end)
    end)
  end
end
