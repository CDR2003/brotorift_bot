defmodule BrotoriftBot.Report do
  use Agent

  def start_link(_args) do
    Agent.start_link(fn -> [] end)
  end

  def connect(agent, start_time, stop_time) do
    action = %{action: "connect", start_time: start_time, stop_time: stop_time}
    update_action(agent, action)
  end

  def check_version(report, start_time, stop_time) do
    action = %{action: "check_version", start_time: start_time, stop_time: stop_time}
    update_action(report, action)
  end

  def send(report, message, time) do
    action = %{action: "send", message: message, time: time}
    update_action(report, action)
  end

  def receive(report, message, start_time, stop_time) do
    action = %{action: "receive", message: message, start_time: start_time, stop_time: stop_time}
    update_action(report, action)
  end

  def get_actions(report) do
    Agent.get(report, &Enum.reverse/1, :infinity)
  end

  defp update_action(report, action) do
    Agent.update(report, fn actions -> [action] ++ actions end)
  end
end
