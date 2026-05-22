defmodule AnythingCompare.DataPipeline.Parser do
  def parse_subjective_field(nil), do: []
  def parse_subjective_field(""), do: []

  def parse_subjective_field(raw_string) when is_binary(raw_string) do
    raw_string
    |> String.split("|", trim: true)
    |> Enum.map(fn entry ->
      case String.split(entry, "@", parts: 2) do
        [raw_value, source] ->
          %{
            "value" => String.trim(raw_value),
            "source" => String.trim(source),
            "numeric_value" => extract_numeric(raw_value)
          }

        [fallback] ->
          %{
            "value" => String.trim(fallback),
            "source" => "Generic",
            "numeric_value" => extract_numeric(fallback)
          }
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  def parse_csv_rows(rows, schema) do
    [headers | data_rows] = rows
    schema_keys = Map.keys(schema)

    data_rows
    |> Enum.map(fn row ->
      row_data = Enum.zip(headers, row) |> Map.new()

      specs =
        schema_keys
        |> Enum.reduce(%{}, fn key, acc ->
          raw_value = Map.get(row_data, key)
          field_schema = Map.get(schema, key, %{})

          case field_schema["type"] do
            "number" -> Map.put(acc, key, normalize_number(raw_value))
            "subjective" -> Map.put(acc, key, parse_subjective_field(raw_value))
            _ -> Map.put(acc, key, raw_value)
          end
        end)

      slug = normalize_slug(row_data)

      %{
        "slug" => slug,
        "name" => Map.get(row_data, "name") || Map.get(row_data, "model") || slug,
        "specs" => specs
      }
    end)
  end

  defp normalize_slug(row_data) do
    brand = Map.get(row_data, "brand", "")
    model = Map.get(row_data, "model", row_data["name"] || "")

    "#{brand}-#{model}"
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  defp normalize_number(nil), do: nil
  defp normalize_number(""), do: nil

  defp normalize_number(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} ->
        num

      :error ->
        case Integer.parse(value) do
          {num, _} -> num
          :error -> value
        end
    end
  end

  defp normalize_number(value), do: value

  defp extract_numeric(value) do
    case Regex.run(~r/\d+\.?\d*/, value) do
      [num_str] ->
        case Float.parse(num_str) do
          {num, ""} -> num
          _ -> String.to_integer(num_str)
        end

      nil ->
        nil
    end
  end
end
