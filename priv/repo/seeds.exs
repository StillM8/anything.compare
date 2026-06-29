alias AnythingCompare.Repo
alias AnythingCompare.DataPipeline

# Source of truth lives in /data/{category}/schema.json + data.csv.
# This loader reads from disk and triggers ingestion via the same pipeline
# the webhook worker uses, so dev/prod share one ingestion code path.

data_root = Path.join([File.cwd!(), "data"])

if File.exists?(data_root) do
  data_root
  |> File.ls!()
  |> Enum.each(fn category ->
    schema_path = Path.join([data_root, category, "schema.json"])
    csv_path = Path.join([data_root, category, "data.csv"])

    cond do
      File.exists?(schema_path) and File.exists?(csv_path) ->
        schema = schema_path |> File.read!() |> Jason.decode!()
        csv = csv_path |> File.read!() |> NimbleCSV.RFC4180.parse_string()

        {:ok, count} = DataPipeline.process_ingestion(category, schema, csv)
        IO.puts("Seeded #{(Map.get(schema, "slug", category) |> to_string())} #{count} from /data/#{category}/data.csv")

      true ->
        :ok
    end
  end)
else
  IO.puts("No /data directory found at #{data_root}. Skipping data load.")
end
