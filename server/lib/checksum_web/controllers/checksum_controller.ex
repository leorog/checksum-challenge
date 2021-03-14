defmodule ChecksumWeb.ChecksumController do
  use ChecksumWeb, :controller

  def process_command(conn, params) do
    text(conn, Checksum.process_command(params))
  end
end
