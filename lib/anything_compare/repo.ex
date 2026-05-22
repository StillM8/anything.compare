defmodule AnythingCompare.Repo do
  use Ecto.Repo,
    otp_app: :anything_compare,
    adapter: Ecto.Adapters.Postgres
end
