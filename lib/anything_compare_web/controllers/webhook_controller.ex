defmodule AnythingCompareWeb.WebhookController do
  use AnythingCompareWeb, :controller

  def github(conn, _params) do
    {:ok, raw_body, conn} = Plug.Conn.read_body(conn)

    signature = get_req_header(conn, "x-hub-signature-256") |> List.first()
    secret = Application.get_env(:anything_compare, :github_webhook_secret)

    if signature && verify_signature(raw_body, signature, secret) do
      payload = Jason.decode!(raw_body)
      handle_push_event(payload)
      json(conn, %{status: "ok"})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "invalid signature"})
    end
  end

  defp verify_signature(body, signature, secret) when is_binary(secret) do
    computed =
      "sha256=" <> (:crypto.mac(:hmac, :sha256, secret, body) |> Base.encode16(case: :lower))

    Plug.Crypto.secure_compare(computed, signature)
  end

  defp verify_signature(_body, _signature, nil), do: false

  defp handle_push_event(%{"ref" => "refs/heads/main", "commits" => commits}) do
    categories = extract_affected_categories(commits)

    Enum.each(categories, fn category ->
      %{category: category, csv_url: csv_url(category), schema_url: schema_url(category)}
      |> AnythingCompare.Workers.CategorySyncWorker.new()
      |> Oban.insert()
    end)
  end

  defp handle_push_event(_), do: :ok

  defp extract_affected_categories(commits) do
    commits
    |> Enum.flat_map(fn commit ->
      (commit["added"] ++ commit["modified"] ++ commit["removed"])
      |> Enum.filter(&String.starts_with?(&1, "data/"))
      |> Enum.map(&(String.split(&1, "/") |> Enum.at(1)))
    end)
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
  end

  defp csv_url(category),
    do: "https://raw.githubusercontent.com/anything-compare/data/main/data/#{category}/data.csv"

  defp schema_url(category),
    do:
      "https://raw.githubusercontent.com/anything-compare/data/main/data/#{category}/schema.json"
end
