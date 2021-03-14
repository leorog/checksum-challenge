defmodule Checksum.ChecksumAgent do
  use Agent

  @timeout 15

  def child_spec(opts) do
    %{
      id: opts[:name],
      start: {__MODULE__, :start_link, [opts[:name]]},
      restart: :permanent,
      type: :worker
    }
  end

  def start_link(name) do
    Agent.start_link(fn -> :queue.new() end, name: name)
  end

  def add(agent, number) do
    Agent.update(agent, fn q -> :queue.in(number, q) end, @timeout)
  end

  def clear(agent) do
    Agent.update(agent, fn _q -> :queue.new() end, @timeout)
  end

  def get(agent) do
    Agent.get(agent, fn q -> :queue.to_list(q) end, @timeout)
  end
end
