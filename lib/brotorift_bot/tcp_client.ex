defmodule BrotoriftBot.TcpClient do
  use GenServer

  @cs_packet_data 1
  @cs_packet_client_version 2
  @cs_heartbeat 3

  @sc_packet_version_check_result 129

  @spec start_link({pid, pid}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @spec connect(pid, non_neg_integer, :infinity | non_neg_integer) :: :ok
  def connect(client, version, timeout \\ :infinity) do
    GenServer.call(client, {:connect, version}, timeout)
  end

  @spec send_packet(pid, binary) :: :ok
  def send_packet(client, data) do
    GenServer.cast(client, {:send, data})
  end

  def init({report, protocol}) do
    {:ok, {report, protocol}}
  end

  def handle_call({:connect, version}, _from, {report, protocol}) do
    {:ok, host} = Application.fetch_env(:brotorift_bot, :host)
    {:ok, port} = Application.fetch_env(:brotorift_bot, :port)

    start_time = Time.utc_now()
    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, {:active, false}, {:packet, 0}])
    stop_time = Time.utc_now()
    BrotoriftBot.Report.connect(report, start_time, stop_time)

    true = check_version(report, socket, version)

    {:ok, _receiver} = BrotoriftBot.TcpReceiverSupervisor.create_receiver(report, protocol, socket)

    do_heartbeat(socket)

    {:reply, :ok, {report, protocol, socket}}
  end

  def handle_cast({:send, data}, {report, protocol, socket}) do
    {:ok, data_head} = Application.fetch_env(:brotorift_bot, :data_head)
    data = <<data_head::32-little-signed, @cs_packet_data::8, byte_size(data)::32-little, data::binary>>
    :ok = :gen_tcp.send(socket, data)
    {:noreply, {report, protocol, socket}}
  end

  def handle_info(:heartbeat, {report, protocol, socket}) do
    do_heartbeat(socket)
    {:noreply, {report, protocol, socket}}
  end

  defp check_version(report, socket, version) do
    {:ok, data_head} = Application.fetch_env(:brotorift_bot, :data_head)
    packet = <<data_head::32-little-signed, @cs_packet_client_version::8, version::32-little-signed>>
    :ok = :gen_tcp.send(socket, packet)

    start_time = Time.utc_now()
    {:ok, <<@sc_packet_version_check_result::8>>} = :gen_tcp.recv(socket, 1)
    {:ok, <<client_version::32-little-signed, server_version::32-little-signed>>} = :gen_tcp.recv(socket, 8)
    stop_time = Time.utc_now()
    BrotoriftBot.Report.check_version(report, start_time, stop_time)

    client_version == server_version
  end

  defp do_heartbeat(socket) do
    {:ok, data_head} = Application.fetch_env(:brotorift_bot, :data_head)
    packet = <<data_head::32-little-signed, @cs_heartbeat::8>>
    :ok = :gen_tcp.send(socket, packet)

    {:ok, heartbeat_interval} = Application.fetch_env(:brotorift_bot, :heartbeat_interval)
    Process.send_after(self(), :heartbeat, heartbeat_interval)
  end
end
