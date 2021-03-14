defmodule Checksum do
  alias Checksum.ChecksumAgent
  alias Checksum.Logic

  def process_command(params) do
    checksum_id = Logic.checksum_id(params["id"])
    DynamicSupervisor.start_child(ChecksumStateSupervisor, {ChecksumAgent, name: checksum_id})

    case Logic.read_command(params["command"]) do
      {:ok, :checksum} ->
        checksum_id
        |> ChecksumAgent.get
        |> Logic.checksum

      {:ok, {:add, number}} ->
        ChecksumAgent.add(checksum_id, number)

      {:ok, :clear} ->
        ChecksumAgent.clear(checksum_id)

      {:error, error} ->
        error
    end
  end
end
