defmodule AnythingCompareWeb.Router do
  use AnythingCompareWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AnythingCompareWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AnythingCompareWeb.Plugs.Subdomain
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AnythingCompareWeb do
    pipe_through :browser

    live "/", CatalogLive.Index, :index
    live "/:category", CatalogLive.Index, :index
    live "/compare/:slugs", CatalogLive.Compare, :compare
    live "/:category/compare/:slugs", CatalogLive.Compare, :compare
    live "/product/:slug", CatalogLive.Detail, :show
    live "/:category/product/:slug", CatalogLive.Detail, :show
  end

  scope "/webhooks", AnythingCompareWeb do
    pipe_through :api

    post "/github", WebhookController, :github
  end

  if Application.compile_env(:anything_compare, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AnythingCompareWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
