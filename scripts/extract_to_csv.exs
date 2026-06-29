# Run with: mix run scripts/extract_to_csv.exs
# One-time conversion: extracts schema + phones from seeds.exs to /data/phones/{schema.json, data.csv}

data_dir = Path.join([File.cwd!(), "data", "phones"])
File.mkdir_p!(data_dir)

{_result, bindings} =
  Path.join([File.cwd!(), "priv", "repo", "seeds.exs"])
  |> File.read!()
  |> Code.eval_string()

phones_schema = Keyword.fetch!(bindings, :phones_schema)

# seeds.exs may split phones across `phones` and `new_phones` lists — combine.
all_phones =
  [Keyword.get(bindings, :phones, []), Keyword.get(bindings, :new_phones, [])]
  |> Enum.flat_map(&(&1 || []))
  |> Enum.uniq()
  |> Enum.sort_by(fn p -> p.slug end)

# Write schema.json
File.write!(
  Path.join(data_dir, "schema.json"),
  Jason.encode!(phones_schema, pretty: true)
)

IO.puts("Wrote schema.json with #{map_size(phones_schema)} keys")

# CSV helpers
quote = fn str ->
  str = to_string(str)

  if String.contains?(str, [",", "\"", "\n", "|"]) do
    "\"" <> String.replace(str, "\"", "\"\"") <> "\""
  else
    str
  end
end

encode_value = fn
  v when is_number(v) -> to_string(v)
  v when is_list(v) ->
    Enum.map_join(v, " | ", fn entry ->
      "#{entry["value"]}@#{entry["source"]}"
    end)
    |> quote.()
  v when is_binary(v) -> quote.(v)
  v when is_nil(v) -> ""
  v -> quote.(v)
end

schema_keys = Map.keys(phones_schema)
header = Enum.join(schema_keys, ",")

csv =
  [header | Enum.map(all_phones, fn product ->
    Enum.map_join(schema_keys, ",", fn key ->
      encode_value.(Map.get(product.specs, key, ""))
    end)
  end)]
  |> Enum.join("\n")
  |> Kernel.<>("\n")

File.write!(Path.join(data_dir, "data.csv"), csv)
IO.puts("Wrote data.csv with #{length(all_phones)} rows")
