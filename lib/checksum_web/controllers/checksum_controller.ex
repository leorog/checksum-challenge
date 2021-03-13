defmodule ChecksumWeb.ChecksumController do
  use ChecksumWeb, :controller
  alias Checksum.ChecksumAgent
  alias Checksum.Logic

  # TODO: commands can be a list and storage must be atomic
  # TODO: validate operation result
  # TODO: cleanup states

  def add(conn, %{command: n}) do
    id
    |> Logic.checksum_state_pid
    |> ChecksumAgent.add(n)

    text(conn, :ok)
  end

  def checksum(conn, %{id: id}) do
    checksum = id
      |> Logic.checksum_state_pid
      |> ChecksumAgent.get
      |> Logic.checksum()

    text(conn, checksum)
  end

  def clear(conn, %{id: id}) do
    id
    |> Logic.checksum_state_pid
    |> ChecksumAgent.clear

    text(conn, :ok)
  end

  def clear_all(conn, %{id: id}) do
    text(conn, :ok)
  end
end
