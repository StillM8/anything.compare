defmodule AnythingCompare.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AnythingCompareWeb.Telemetry,
      AnythingCompare.Repo,
      {DNSCluster, query: Application.get_env(:anything_compare, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AnythingCompare.PubSub},
      {Oban, Application.get_env(:anything_compare, Oban)},
      AnythingCompare.Cache.Storage,
      AnythingCompareWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AnythingCompare.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AnythingCompareWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
