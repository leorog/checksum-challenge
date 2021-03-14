defmodule ChecksumWeb.Router do
  use ChecksumWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/v1", ChecksumWeb do
    pipe_through(:api)

    post("/number", ChecksumController, :process_command)
  end
end
