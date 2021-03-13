defmodule Checksum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ChecksumWeb.Telemetry,
      ChecksumWeb.Endpoint,
      {Registry, keys: :unique, name: ChecksumRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: ChecksumStateSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Checksum.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ChecksumWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
