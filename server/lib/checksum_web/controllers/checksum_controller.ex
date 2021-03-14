defmodule ChecksumWeb.ChecksumController do
  use ChecksumWeb, :controller

  def process_command(conn, params) do
    result = Checksum.process_command(params)
    json(conn, %{data: result})
  end
end
