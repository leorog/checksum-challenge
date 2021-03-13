defmodule ChecksumWeb.Router do
  use ChecksumWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/v1", ChecksumWeb do
    pipe_through :api

    post "/number/:id/add", ChecksumWeb.ChecksumController, :add
    get "/number/:id/checksum", ChecksumWeb.ChecksumController, :checksum
    delete "/number/:id/clear", ChecksumWeb.ChecksumController, :clear
    delete "/number/clear-all", ChecksumWeb.ChecksumController, :clear_all
  end
end
