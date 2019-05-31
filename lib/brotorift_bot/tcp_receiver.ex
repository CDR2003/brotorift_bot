defmodule BrotoriftBot.TcpReceiver do
  use GenServer

  @sc_packet_data 128
  @sc_packet_version_check_result 129
  @sc_heartbeat 130

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def recv_packet(receiver) do
    GenServer.cast(receiver, :recv)
  end

  def init({report, protocol, socket}) do
    recv_packet(self())
    {:ok, {report, protocol, socket}}
  end

  def handle_cast(:recv, {report, protocol, socket}) do
    {:ok, <<packet_type::8>>} = :gen_tcp.recv(socket, 1)
    case packet_type do
      @sc_packet_data ->
        {:ok, <<packet_size::32-little>>} = :gen_tcp.recv(socket, 4)
        {:ok, data} = :gen_tcp.recv(socket, packet_size)
        <<header::32-little, data::binary>> = data
        send(protocol, {header, data})
        recv_packet(self())
      @sc_packet_version_check_result ->
        :gen_tcp.recv(socket, 8)
        recv_packet(self())
      @sc_heartbeat ->
        recv_packet(self())
    end
    {:noreply, {report, protocol, socket}}
  end
end
