defmodule AnythingCompareWeb.CatalogLive.Detail do
  use AnythingCompareWeb, :live_view

  @spec_groups %{
    "Overview" => ~w(brand model os),
    "Display" => ~w(display_size resolution refresh_rate),
    "Performance" => ~w(processor ram_gb storage_gb),
    "Battery" => ~w(battery_mah charging_w wireless_charging),
    "Camera" => ~w(camera_main_mp camera_ultrawide_mp camera_telephoto_mp front_camera_mp),
    "Physical" => ~w(weight_g thickness_mm ip_rating headphone_jack),
    "Benchmarks" => ~w(stability gpu_score cpu_score battery_drain)
  }

  @dev_routes Application.compile_env(:anything_compare, :dev_routes, false)

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand"},
    "model" => %{"type" => "string", "label" => "Model"},
    "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\""},
    "resolution" => %{"type" => "string", "label" => "Resolution"},
    "refresh_rate" => %{"type" => "number", "label" => "Refresh Rate", "unit" => "Hz"},
    "processor" => %{"type" => "string", "label" => "Processor"},
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB"},
    "battery_mah" => %{
      "type" => "number",
      "label" => "Battery",
      "unit" => "mAh",
      "visual" => "bar"
    },
    "charging_w" => %{"type" => "number", "label" => "Charging", "unit" => "W"},
    "wireless_charging" => %{"type" => "string", "label" => "Wireless Charging"},
    "camera_main_mp" => %{"type" => "number", "label" => "Main Camera", "unit" => "MP"},
    "camera_ultrawide_mp" => %{"type" => "number", "label" => "Ultrawide", "unit" => "MP"},
    "camera_telephoto_mp" => %{"type" => "number", "label" => "Telephoto", "unit" => "MP"},
    "front_camera_mp" => %{"type" => "number", "label" => "Front Camera", "unit" => "MP"},
    "os" => %{"type" => "string", "label" => "OS"},
    "weight_g" => %{"type" => "number", "label" => "Weight", "unit" => "g"},
    "thickness_mm" => %{"type" => "number", "label" => "Thickness", "unit" => "mm"},
    "ip_rating" => %{"type" => "string", "label" => "Water Resistance"},
    "headphone_jack" => %{"type" => "string", "label" => "Headphone Jack"},
    "stability" => %{"type" => "subjective", "label" => "Stability"},
    "gpu_score" => %{"type" => "subjective", "label" => "GPU Score"},
    "cpu_score" => %{"type" => "subjective", "label" => "CPU Score"},
    "battery_drain" => %{"type" => "subjective", "label" => "Battery Drain", "unit" => "h"}
  }

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, :current_category, current_category)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    slug = params["slug"] || ""

    product = AnythingCompare.Catalog.get_product!(category, slug)
    schema = AnythingCompare.Cache.Storage.get_schema(category)
    effective_schema = if schema == %{}, do: @sample_schema, else: schema

    # Build grouped sections
    grouped = build_groups(effective_schema)

    {:noreply,
     assign(socket,
       category: category,
       product: product,
       schema: effective_schema,
       grouped_schema: grouped,
       page_title: "#{product.name} | anything.compare",
       dev_routes: @dev_routes
     )}
  end

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
  end

  defp build_groups(schema) do
    ordered_schema =
      @spec_groups
      |> Enum.flat_map(fn {_, keys} -> keys end)
      |> Enum.map(fn key -> {key, schema[key]} end)
      |> Enum.filter(fn {_, v} -> v != nil end)

    # Also include any schema keys not in the groups
    grouped_keys = Enum.flat_map(@spec_groups, fn {_, keys} -> keys end)

    extra =
      schema
      |> Enum.reject(fn {k, _} -> k in grouped_keys end)
      |> Enum.map(fn {k, v} -> {k, v} end)

    all_ordered = ordered_schema ++ extra

    @spec_groups
    |> Enum.map(fn {group_name, group_keys} ->
      matched = Enum.filter(all_ordered, fn {k, _} -> k in group_keys end)
      {group_name, matched}
    end)
    |> Enum.filter(fn {_, specs} -> specs != [] end)
    |> then(fn grouped ->
      grouped_flat = Enum.flat_map(grouped, fn {_, specs} -> specs end)
      grouped_keys = Enum.map(grouped_flat, &elem(&1, 0))
      ungrouped = Enum.reject(all_ordered, fn {k, _} -> k in grouped_keys end)

      if ungrouped != [] do
        grouped ++ [{"Other", ungrouped}]
      else
        grouped
      end
    end)
  end

  defp compare_url(category, slug) do
    ~p"/#{category}/compare/#{slug}"
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <div class="max-w-4xl mx-auto px-4 py-6 sm:py-10">
          <%!-- Breadcrumb --%>
          <nav class="flex items-center gap-2 text-xs sm:text-sm opacity-50 mb-4 sm:mb-6">
            <.link navigate={~p"/"} class="hover:opacity-100 transition-opacity">Home</.link>
            <span>/</span>
            <.link
              navigate={~p"/#{@category}"}
              class="hover:opacity-100 transition-opacity capitalize"
            >
              {@category}
            </.link>
            <span>/</span>
            <span class="opacity-100 font-medium">{@product.name}</span>
          </nav>

          <%!-- Hero section --%>
          <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4 mb-8 sm:mb-10">
            <div>
              <div class="flex items-center gap-2 mb-1">
                <span class="spec-badge bg-primary/10 text-primary text-xs">
                  {String.capitalize(@category)}
                </span>
              </div>
              <h1 class="text-2xl sm:text-4xl font-bold tracking-tight">{@product.name}</h1>
              <p class="text-sm sm:text-base opacity-50 mt-1.5 max-w-lg leading-relaxed">
                Full specifications and benchmark data for this product.
              </p>
            </div>
            <div class="flex items-center gap-2 shrink-0">
              <.link
                navigate={compare_url(@category, @product.slug)}
                class="btn btn-primary btn-sm sm:btn-md gap-1.5"
              >
                <.icon name="hero-arrows-right-left" class="w-4 h-4" /> Compare
              </.link>
              <%= if @dev_routes == true do %>
                <.link
                  href="https://github.com/anything-compare/data/edit/main/data/#{@category}/data.csv"
                  class="btn btn-ghost btn-sm sm:btn-md gap-1.5"
                >
                  <.icon name="hero-pencil-square" class="w-4 h-4" /> Edit data
                </.link>
              <% end %>
            </div>
          </div>

          <%!-- Spec sections --%>
          <div class="space-y-6 sm:space-y-8">
            <%= for {group_name, specs} <- @grouped_schema do %>
              <div class="rounded-xl border border-base-300 bg-base-100 shadow-sm overflow-hidden">
                <div class="px-4 sm:px-6 py-3 bg-gradient-to-r from-primary/[0.04] to-transparent border-b border-base-300">
                  <div class="flex items-center gap-2">
                    <div class="w-1 h-4 rounded-full bg-gradient-to-b from-primary to-secondary">
                    </div>
                    <h2 class="font-semibold text-sm sm:text-base tracking-tight">{group_name}</h2>
                  </div>
                </div>
                <div class="divide-y divide-base-200">
                  <%= for {spec_key, spec_meta} <- specs do %>
                    <div class="px-4 sm:px-6 py-3 sm:py-4 flex items-start justify-between gap-4">
                      <div class="flex items-center gap-2 min-w-0 shrink-0 w-[35%] sm:w-[30%]">
                        <span class="text-xs sm:text-sm font-medium">{spec_meta["label"]}</span>
                        <span :if={spec_meta["unit"]} class="text-[10px] sm:text-xs opacity-40">
                          {spec_meta["unit"]}
                        </span>
                      </div>
                      <div class="flex-1 min-w-0">
                        <.detail_spec_value
                          value={@product.specs[spec_key]}
                          meta={spec_meta}
                        />
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>

          <%!-- Footer CTA --%>
          <div class="mt-10 sm:mt-12 text-center p-6 sm:p-8 rounded-xl border border-dashed border-base-300 bg-base-200/30">
            <p class="text-sm sm:text-base opacity-60 mb-3">
              Want to compare this product side-by-side with others?
            </p>
            <.link
              navigate={compare_url(@category, @product.slug)}
              class="btn btn-primary gap-2"
            >
              <.icon name="hero-arrows-right-left" class="w-4 h-4" /> Open Comparison
            </.link>
            <p class="text-xs opacity-40 mt-3">
              Data missing or incorrect?
              <a
                href="https://github.com/anything-compare/data"
                class="underline hover:opacity-100"
              >
                Contribute on GitHub
              </a>
            </p>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :value, :any
  attr :meta, :map, default: %{}

  def detail_spec_value(assigns) do
    ~H"""
    <div>
      <%= cond do %>
        <% is_nil(@value) or @value == "" -> %>
          <span class="opacity-30 text-xs sm:text-sm italic">No data — contribute on GitHub</span>
        <% is_list(@value) -> %>
          <%!-- Subjective multi-source breakdown --%>
          <div class="space-y-2">
            <%= for entry <- @value do %>
              <div class="flex items-center gap-3">
                <span
                  class="text-[10px] sm:text-xs opacity-50 w-20 sm:w-24 shrink-0 truncate text-right"
                  title={entry["source"]}
                >
                  {entry["source"]}
                </span>
                <div class="flex-1 h-5 sm:h-6 rounded-md bg-base-300 overflow-hidden relative">
                  <div
                    class="h-full rounded-md bg-primary/40 spec-bar flex items-center justify-end pr-1.5"
                    style={"width: #{min(100, entry["numeric_value"] || 0)}%"}
                  >
                    <span class="text-[10px] sm:text-xs font-semibold text-white/90 drop-shadow-sm">
                      {entry["value"]}
                    </span>
                  </div>
                </div>
              </div>
            <% end %>
            <% numeric_vals = Enum.map(@value, & &1["numeric_value"]) |> Enum.reject(&is_nil/1) %>
            <%= if numeric_vals != [] do %>
              <div class="flex items-center gap-2 pt-1 border-t border-base-300/50 mt-1">
                <span class="text-[10px] sm:text-xs opacity-50 w-20 sm:w-24 shrink-0 text-right">
                  Average
                </span>
                <span class="text-xs sm:text-sm font-bold tabular-nums">
                  {round(Enum.sum(numeric_vals) / length(numeric_vals))}%
                </span>
                <div class="text-[10px] sm:text-xs opacity-40">
                  across {length(numeric_vals)} sources
                </div>
              </div>
            <% end %>
          </div>
        <% is_number(@value) -> %>
          <div class="flex items-center gap-3">
            <span class="text-sm sm:text-base font-bold tabular-nums">
              {@value}{@meta["unit"]}
            </span>
            <%= if @meta["visual"] == "bar" do %>
              <div class="flex-1 max-w-xs h-2 rounded-full bg-base-300 overflow-hidden">
                <div
                  class="h-full rounded-full bg-primary/50 spec-bar"
                  style={"width: #{min(100, @value)}%"}
                />
              </div>
            <% end %>
          </div>
        <% true -> %>
          <span class="text-sm sm:text-base font-medium">{@value}</span>
      <% end %>
    </div>
    """
  end
end
