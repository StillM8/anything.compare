import Config

config :anything_compare,
  ecto_repos: [AnythingCompare.Repo],
  generators: [timestamp_type: :utc_datetime],
  data_repo_url: "https://github.com/StillM8/anything.compare/edit/main"

config :anything_compare, AnythingCompareWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AnythingCompareWeb.ErrorHTML, json: AnythingCompareWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AnythingCompare.PubSub,
  live_view: [signing_salt: "lG3OOMYm"]

config :anything_compare, AnythingCompare.Mailer, adapter: Swoosh.Adapters.Local

config :anything_compare, Oban,
  repo: AnythingCompare.Repo,
  queues: [ingestion: 1, default: 10]

config :esbuild,
  version: "0.25.4",
  anything_compare: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

config :tailwind,
  version: "4.1.12",
  anything_compare: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
