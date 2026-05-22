defmodule AnythingCompare.Workers.CategorySyncWorker do
  use Oban.Worker, queue: :ingestion, max_attempts: 3

  alias AnythingCompare.DataPipeline

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"category" => category, "csv_url" => csv_url, "schema_url" => schema_url}
      }) do
    with {:ok, schema_data} <- fetch_json(schema_url),
         {:ok, csv_rows} <- fetch_csv(csv_url) do
      DataPipeline.process_ingestion(category, schema_data, csv_rows)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_json(url) do
    %Req.Response{status: 200, body: body} = Req.get!(url)
    {:ok, Jason.decode!(body)}
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp fetch_csv(url) do
    %Req.Response{status: 200, body: body} = Req.get!(url)
    rows = NimbleCSV.RFC4180.parse_string(body)
    {:ok, rows}
  rescue
    e -> {:error, Exception.message(e)}
  end
end
