defmodule PingPongServer.Client do
  use GenServer

  @version 1

  @header_ping 1001
  @header_pong 2001

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def connect(client) do
    GenServer.call(client, :connect, :infinity)
  end

  def send_ping(client) do
    GenServer.cast(client, {:send, :ping})
  end

  def receive_pong(client) do
    GenServer.call(client, {:receive, :pong}, :infinity)
  end

  def init(_args) do
    {:ok, report} = BrotoriftBot.ReportManager.create_report()
    {:ok, tcp_client} = BrotoriftBot.TcpClientSupervisor.create_client(report, self())
    {:ok, {report, tcp_client}}
  end

  def handle_call(:connect, _from, {report, tcp_client}) do
    BrotoriftBot.TcpClient.connect(tcp_client, @version)
    {:reply, :ok, {report, tcp_client}}
  end

  def handle_call({:receive, :pong}, _from, {report, tcp_client}) do
    start_time = Time.utc_now()
    data = try_receive(@header_pong, tcp_client)
    stop_time = Time.utc_now()
    BrotoriftBot.Report.receive(report, :pong, start_time, stop_time)

    content = parse_packet(:pong, data)
    {:reply, {:ok, content}, {report, tcp_client}}
  end

  def handle_cast({:send, :ping}, {report, tcp_client}) do
    data = <<@header_ping::32-little>>
    time = Time.utc_now()
    :ok = BrotoriftBot.TcpClient.send_packet(tcp_client, data)
    BrotoriftBot.Report.send(report, :ping, time)
    {:noreply, {report, tcp_client}}
  end

  defp try_receive(message, tcp_client) do
    receive do
      {^message, value} ->
        value
      _ ->
        try_receive(message, tcp_client)
    end
  end

  defp parse_packet(:pong, data) do
    {data, count} = Brotorift.Binary.read_int(data)
    <<>> = data
    {count}
  end
end
