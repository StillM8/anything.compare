defmodule AnythingCompareWeb.Plugs.Subdomain do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    host = conn.host
    parts = String.split(host, ".")

    current_category =
      case parts do
        [subdomain, "anything", "compare"] when subdomain not in ["www", "api"] ->
          subdomain

        [subdomain, "anything", "compare", "local" <> _] when subdomain not in ["www", "api"] ->
          subdomain

        _ ->
          "root"
      end

    conn
    |> assign(:current_category, current_category)
    |> put_session(:current_category, current_category)
  end
end
