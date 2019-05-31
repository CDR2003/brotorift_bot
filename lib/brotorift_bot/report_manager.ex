defmodule BrotoriftBot.ReportManager do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    start_time = Time.utc_now()
    {:ok, {start_time, []}}
  end

  def create_report() do
    GenServer.call(__MODULE__, :create_report, :infinity)
  end

  def generate_reports() do
    GenServer.cast(__MODULE__, :generate_reports)
  end

  def handle_call(:create_report, _from, {start_time, reports}) do
    {:ok, report} = BrotoriftBot.ReportSupervisor.create_report()
    {:reply, {:ok, report}, {start_time, [report] ++ reports}}
  end

  def handle_cast(:generate_reports, {start_time, reports}) do
    bot_reports = Enum.map(reports, &BrotoriftBot.Report.get_actions/1)
    full_report = %{start_time: start_time, bots: bot_reports}

    {:ok, file} = File.open("report.json", [:write])
    content = Poison.encode!(full_report)
    IO.binwrite(file, content)

    IO.puts "Report.json generated."

    {:noreply, {start_time, reports}}
  end
end
