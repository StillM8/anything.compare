defmodule AnythingCompare.Comparisons do
  @moduledoc """
  Schema-driven comparison engine.
  Works with any category — no hardcoded phone-specific fields.
  """

  alias AnythingCompare.Comparisons.Meta

  @doc """
  Order specs naturally: brand/model/name first, then key order from schema.
  """
  def order_specs(schema) do
    preference = ~w(brand model name)

    {preferred, rest} =
      schema
      |> Enum.map(fn {k, v} -> {k, v} end)
      |> Enum.split_with(fn {k, _} -> k in preference end)

    preferred ++ rest
  end

  @doc """
  Group ordered specs into sections.
  Uses explicit `group` from schema.json metadata, or derives group from key prefix.
  Single-key groups are merged into "Other" unless they're a major group.
  """
  def group_specs(ordered_schema) do
    grouped_map =
      Enum.group_by(ordered_schema, fn {key, meta} ->
        Meta.group_for(key, meta)
      end)

    grouped_map
    |> Enum.map(fn {group, specs} ->
      {group, specs}
    end)
    |> Enum.sort_by(fn {group, _} -> {Meta.group_order(group), group} end)
    |> then(fn sorted ->
      # Anything that didn't match a known prefix goes to "Other"
      Enum.reduce(sorted, [], fn
        {nil, specs}, acc -> acc ++ [{"Other", specs}]
        {group, specs}, acc -> acc ++ [{group, specs}]
      end)
    end)
  end

  @doc """
  Find which spec keys have differing values across products.
  """
  def diff_keys(products) do
    case products do
      [] ->
        []

      [single] ->
        Map.keys(single.specs || %{})

      [first | rest] ->
        first_specs = Map.get(first, :specs) || %{}

        Map.keys(first_specs)
        |> Enum.filter(fn key ->
          first_val = normalize_for_diff(first_specs[key])

          Enum.any?(rest, fn p ->
            val = Map.get(p.specs || %{}, key)
            normalize_for_diff(val) != first_val
          end)
        end)
    end
  end

  defp normalize_for_diff(nil), do: ""
  defp normalize_for_diff(v) when is_list(v), do: inspect(v)
  defp normalize_for_diff(v), do: v

  @doc """
  Best (highest or lowest) numeric value for a spec across products.
  Defaults to higher-is-better. Override via `"higher_better": false` in schema metadata.
  """
  def best_value(spec_key, products, schema) do
    meta = schema[spec_key]
    higher_better = if is_map(meta), do: Map.get(meta, "higher_better", true), else: true

    values =
      products
      |> Enum.map(fn p -> Map.get(p.specs || %{}, spec_key) end)
      |> Enum.filter(&is_number/1)

    case values do
      [] -> nil
      _ -> if(higher_better, do: Enum.max(values), else: Enum.min(values))
    end
  end

  @doc """
  Relative bar width (0-100) for a numeric value compared to peers.
  """
  def bar_width(value, spec_key, products) do
    values =
      products
      |> Enum.map(fn p -> Map.get(p.specs || %{}, spec_key) end)
      |> Enum.filter(&is_number/1)

    cond do
      values == [] or is_nil(value) ->
        0

      true ->
        max_val = Enum.max(values)
        min_val = Enum.min(values)
        range = max_val - min_val

        if range == 0 do
          100
        else
          round((value - min_val) / range * 85) + 15
        end
    end
  end

  @doc """
  Aggregate subjective (multi-source) values.
  Returns %{average: float | nil, count: integer, sources: list}.
  """
  def aggregate_subjective(values) when is_list(values) do
    numeric = Enum.map(values, & &1["numeric_value"]) |> Enum.reject(&is_nil/1)

    case numeric do
      [] ->
        %{average: nil, count: 0, sources: values}

      vals ->
        %{
          average: round(Enum.sum(vals) / length(vals)),
          count: length(vals),
          sources: values
        }
    end
  end

  def aggregate_subjective(_), do: %{average: nil, count: 0, sources: []}

  @doc """
  Build compare URL path from category and slug list.
  """
  def compare_path(category, slugs) when is_list(slugs) do
    "/#{category}/compare/#{Enum.join(slugs, "-vs-")}"
  end

  def compare_path(category, slug) when is_binary(slug) do
    "/#{category}/compare/#{slug}"
  end

  @doc """
  Derive a minimal schema from product data when no schema.json is available.
  """
  def derive_schema(products) do
    products
    |> Enum.flat_map(fn p -> Map.keys(p.specs || %{}) end)
    |> Enum.uniq()
    |> Enum.map(fn key ->
      values =
        products
        |> Enum.map(fn p -> Map.get(p.specs || %{}, key) end)
        |> Enum.reject(&is_nil/1)

      inferred_type = infer_type(values)

      {key, %{"label" => Meta.label_for(key), "type" => inferred_type}}
    end)
    |> Map.new()
  end

  defp infer_type(values) do
    cond do
      Enum.all?(values, &is_number/1) -> "number"
      Enum.all?(values, &is_list/1) -> "subjective"
      true -> "string"
    end
  end
end

defmodule AnythingCompare.Comparisons.Meta do
  @moduledoc false

  @doc """
  Determine group name for a spec key.
  Uses explicit `group` from schema metadata, falls back to prefix matching.
  """
  def group_for(key, meta) do
    cond do
      is_map(meta) and meta["group"] -> meta["group"]
      true -> derive_group(key)
    end
  end

  @doc """
  Sort order for groups.
  Performance/Display/Physical on top, Benchmarks last.
  """
  def group_order("Performance"), do: 1
  def group_order("Display"), do: 2
  def group_order("Physical"), do: 3
  def group_order("Overview"), do: 4
  def group_order("Memory"), do: 5
  def group_order("Battery"), do: 6
  def group_order("Camera"), do: 7
  def group_order("Software"), do: 8
  def group_order("Audio"), do: 9
  def group_order("Connectivity"), do: 10
  def group_order("Sensors"), do: 11
  def group_order("Benchmarks"), do: 12
  def group_order(_), do: 50

  @doc """
  Human-readable label for a spec key.
  """
  def label_for(key) do
    key
    |> to_string()
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  @prefix_rules [
    {"battery_drain", "Benchmarks"},
    {"battery", "Battery"},
    {"camera_main", "Camera"},
    {"camera_front", "Camera"},
    {"front_camera", "Camera"},
    {"camera", "Camera"},
    {"aperture", "Camera"},
    {"sensor", "Camera"},
    {"processor", "Performance"},
    {"ram", "Memory"},
    {"memory", "Memory"},
    {"storage", "Memory"},
    {"ssd", "Memory"},
    {"display", "Display"},
    {"screen", "Display"},
    {"resolution", "Display"},
    {"refresh_rate", "Display"},
    {"refresh", "Display"},
    {"brightness", "Display"},
    {"panel", "Display"},
    {"charging", "Battery"},
    {"charge", "Battery"},
    {"wireless", "Battery"},
    {"operating_system", "Software"},
    {"os", "Software"},
    {"weight", "Physical"},
    {"thickness", "Physical"},
    {"dimensions", "Physical"},
    {"ip_rating", "Physical"},
    {"water_resistance", "Physical"},
    {"headphone", "Audio"},
    {"jack", "Audio"},
    {"speaker", "Audio"},
    {"wifi", "Connectivity"},
    {"bluetooth", "Connectivity"},
    {"usb", "Connectivity"},
    {"nfc", "Connectivity"},
    {"network", "Connectivity"},
    {"5g", "Connectivity"},
    {"sim", "Connectivity"},
    {"port", "Connectivity"},
    {"hdmi", "Connectivity"},
    {"stability", "Benchmarks"},
    {"benchmark", "Benchmarks"},
    {"score", "Benchmarks"},
    {"geekbench", "Benchmarks"},
    {"antutu", "Benchmarks"},
    {"3dmark", "Benchmarks"},
    {"speed", "Benchmarks"},
    {"cpu", "Benchmarks"},
    {"gpu", "Benchmarks"},
    {"soc", "Performance"},
    {"chip", "Performance"},
    {"brand", "Overview"},
    {"model", "Overview"},
    {"name", "Overview"},
    {"price", "Overview"},
    {"cost", "Overview"}
  ]

  defp derive_group(key) do
    key_str = to_string(key)

    case Enum.find(@prefix_rules, fn {prefix, _group} ->
           String.starts_with?(key_str, prefix)
         end) do
      {_prefix, group} -> group
      nil -> nil
    end
  end
end
