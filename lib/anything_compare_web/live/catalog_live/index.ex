defmodule AnythingCompareWeb.CatalogLive.Index do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand", "filterable" => true},
    "model" => %{"type" => "string", "label" => "Model"},
    "os" => %{"type" => "string", "label" => "OS", "filterable" => true},
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
    "camera_main_mp" => %{"type" => "number", "label" => "Main Camera", "unit" => "MP"},
    "camera_ultrawide_mp" => %{"type" => "number", "label" => "Ultrawide", "unit" => "MP"},
    "camera_telephoto_mp" => %{"type" => "number", "label" => "Telephoto", "unit" => "MP"},
    "weight_g" => %{"type" => "number", "label" => "Weight", "unit" => "g"},
    "thickness_mm" => %{"type" => "number", "label" => "Thickness", "unit" => "mm"},
    "ip_rating" => %{"type" => "string", "label" => "Water Resistance"},
    "headphone_jack" => %{"type" => "string", "label" => "Headphone Jack"},
    "stability" => %{"type" => "subjective", "label" => "Stability"},
    "gpu_score" => %{"type" => "subjective", "label" => "GPU Score"},
    "cpu_score" => %{"type" => "subjective", "label" => "CPU Score"}
  }

  # Sortable numeric fields for the sort dropdown
  @sortable_fields ~w(
    display_size refresh_rate ram_gb storage_gb battery_mah charging_w
    camera_main_mp weight_g thickness_mm stability
  )

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"

    {:ok,
     assign(socket,
       current_category: current_category,
       query: "",
       sort_by: nil,
       sort_dir: :desc,
       active_filters: %{},
       selected_slugs: MapSet.new()
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    query = params["q"] || ""
    sort_by = params["sort_by"]
    sort_dir = if params["sort_dir"] == "asc", do: :asc, else: :desc

    socket = assign(socket, :page_title, page_title(category))

    socket =
      if category == "root" do
        categories = AnythingCompare.Catalog.list_categories()
        assign(socket, categories: categories, category: nil)
      else
        products = AnythingCompare.Cache.Storage.get_products(category)
        schema = AnythingCompare.Cache.Storage.get_schema(category)
        effective_schema = if schema == %{}, do: @sample_schema, else: schema

        # Build filter options from schema filterable fields
        filterable_fields = build_filter_options(products, effective_schema)

        # Apply search
        filtered = apply_search(products, query)

        # Apply active filters
        active_filters = Map.get(socket.assigns, :active_filters, %{})
        filtered = apply_filters(filtered, active_filters, effective_schema)

        # Apply sort
        filtered = apply_sort(filtered, sort_by, sort_dir)

        # Determine filter field keys
        filter_fields =
          effective_schema
          |> Enum.filter(fn {_, meta} -> meta["filterable"] end)
          |> Enum.map(fn {key, _} -> key end)

        # Pick preview specs for cards (first ~4 non-filter, non-model specs)
        preview_specs = build_preview_specs(effective_schema)

        assign(socket,
          category: category,
          products: filtered,
          all_products: products,
          product_count: length(products),
          schema: effective_schema,
          query: query,
          sort_by: sort_by,
          sort_dir: sort_dir,
          filterable_fields: filter_fields,
          filter_options: filterable_fields,
          active_filters: active_filters,
          preview_specs: preview_specs,
          sortable_fields: @sortable_fields
        )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"q" => query}, socket) do
    category = socket.assigns.category
    products = socket.assigns.all_products || AnythingCompare.Cache.Storage.get_products(category)
    active_filters = socket.assigns.active_filters || %{}
    schema = socket.assigns.schema || @sample_schema

    filtered = apply_search(products, query)
    filtered = apply_filters(filtered, active_filters, schema)
    filtered = apply_sort(filtered, socket.assigns.sort_by, socket.assigns.sort_dir)

    {:noreply, assign(socket, products: filtered, query: query)}
  end

  @impl true
  def handle_event("toggle-select", %{"slug" => slug}, socket) do
    selected = socket.assigns.selected_slugs

    selected =
      if slug in selected do
        MapSet.delete(selected, slug)
      else
        MapSet.put(selected, slug)
      end

    {:noreply, assign(socket, :selected_slugs, selected)}
  end

  @impl true
  def handle_event("compare-selected", _, socket) do
    slugs = MapSet.to_list(socket.assigns.selected_slugs)

    case slugs do
      [] ->
        {:noreply, socket}

      [single] ->
        {:noreply, push_navigate(socket, to: ~p"/#{socket.assigns.category}/product/#{single}")}

      selected ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/#{socket.assigns.category}/compare/#{Enum.join(selected, "-vs-")}"
         )}
    end
  end

  @impl true
  def handle_event("clear-selection", _, socket) do
    {:noreply, assign(socket, :selected_slugs, MapSet.new())}
  end

  @impl true
  def handle_event("sort", %{"sort_by" => sort_by}, socket) do
    category = socket.assigns.category
    current_sort = socket.assigns.sort_by
    current_dir = socket.assigns.sort_dir

    # Toggle direction if same field, default to desc for new field
    sort_dir =
      if sort_by == current_sort do
        if current_dir == :desc, do: :asc, else: :desc
      else
        :desc
      end

    products = socket.assigns.all_products || AnythingCompare.Cache.Storage.get_products(category)
    query = socket.assigns.query || ""
    active_filters = socket.assigns.active_filters || %{}
    schema = socket.assigns.schema || @sample_schema

    filtered = apply_search(products, query)
    filtered = apply_filters(filtered, active_filters, schema)
    filtered = apply_sort(filtered, sort_by, sort_dir)

    {:noreply, assign(socket, products: filtered, sort_by: sort_by, sort_dir: sort_dir)}
  end

  @impl true
  def handle_event("filter-field", %{"field" => field, "value" => value}, socket) do
    category = socket.assigns.category
    products = socket.assigns.all_products || AnythingCompare.Cache.Storage.get_products(category)
    query = socket.assigns.query || ""

    active_filters = socket.assigns.active_filters || %{}

    active_filters =
      if value == "" do
        Map.delete(active_filters, field)
      else
        Map.put(active_filters, field, value)
      end

    schema = socket.assigns.schema || @sample_schema
    filtered = apply_search(products, query)
    filtered = apply_filters(filtered, active_filters, schema)
    filtered = apply_sort(filtered, socket.assigns.sort_by, socket.assigns.sort_dir)

    {:noreply, assign(socket, products: filtered, active_filters: active_filters)}
  end

  @impl true
  def handle_event("clear-filters", _, socket) do
    category = socket.assigns.category
    products = socket.assigns.all_products || AnythingCompare.Cache.Storage.get_products(category)
    query = socket.assigns.query || ""

    filtered = apply_search(products, query)
    filtered = apply_sort(filtered, socket.assigns.sort_by, socket.assigns.sort_dir)

    {:noreply, assign(socket, products: filtered, active_filters: %{})}
  end

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
  end

  defp page_title("root"), do: "Browse Categories | anything.compare"
  defp page_title(category), do: "#{String.capitalize(category)} | anything.compare"

  defp build_filter_options(products, schema) do
    schema
    |> Enum.filter(fn {_, meta} -> meta["filterable"] end)
    |> Enum.map(fn {key, meta} ->
      values =
        products
        |> Enum.map(fn p -> Map.get(p.specs, key) end)
        |> Enum.reject(&is_nil/1)
        |> Enum.reject(&(&1 == ""))
        |> Enum.uniq()
        |> Enum.sort()

      {key, %{meta: meta, values: values}}
    end)
    |> Map.new()
  end

  defp build_preview_specs(schema) do
    # Schema-driven: fields with `"preview": true` show under each card.
    # `"order": N` controls the order. Falls back to non-brand/model columns
    # if no preview flag is set, so legacy schemas still render.
    preview =
      schema
      |> Enum.filter(fn {_k, meta} -> meta["preview"] == true end)
      |> Enum.sort_by(fn {_k, meta} -> meta["order"] || 0 end)
      |> Enum.take(4)

    if preview == [] do
      schema
      |> Enum.reject(fn {k, _} -> k in ~w(brand model) end)
      |> Enum.take(4)
    else
      preview
    end
  end

  defp apply_search(products, query) do
    if query == "" do
      products
    else
      q = String.downcase(query)

      Enum.filter(products, fn p ->
        String.contains?(String.downcase(p.name), q) ||
          Enum.any?(p.specs, fn {_, v} ->
            is_binary(v) && String.contains?(String.downcase(v), q)
          end)
      end)
    end
  end

  defp apply_filters(products, filters, _schema) when filters == %{}, do: products

  defp apply_filters(products, filters, schema) do
    Enum.reduce(filters, products, fn {field, value}, acc ->
      meta = schema[field]

      cond do
        is_nil(meta) ->
          acc

        meta["type"] == "number" ->
          Enum.filter(acc, fn p ->
            v = Map.get(p.specs, field)
            is_number(v) && "#{v}" == value
          end)

        true ->
          Enum.filter(acc, fn p ->
            Map.get(p.specs, field) == value
          end)
      end
    end)
  end

  defp apply_sort(products, nil, _dir), do: products

  defp apply_sort(products, sort_by, dir) do
    Enum.sort_by(products, fn p ->
      v = Map.get(p.specs, sort_by)

      cond do
        is_number(v) ->
          v

        is_list(v) ->
          vals = Enum.map(v, & &1["numeric_value"]) |> Enum.reject(&is_nil/1)
          if vals == [], do: 0, else: Enum.sum(vals) / length(vals)

        true ->
          0
      end
    end)
    |> then(fn sorted ->
      if dir == :asc, do: sorted, else: Enum.reverse(sorted)
    end)
  end

  defp filter_value_label(field, value, schema) do
    meta = schema[field]

    if meta && meta["unit"] && is_binary(value) do
      "#{value}#{meta["unit"]}"
    else
      value
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <%= if @category == nil do %>
          <%!-- Root landing --%>
          <div class="hero-gradient relative overflow-hidden">
            <%!-- Decorative floating orbs --%>
            <div class="absolute inset-0 overflow-hidden pointer-events-none">
              <div class="absolute top-20 left-10 w-64 h-64 rounded-full bg-primary/5 blur-3xl animate-float">
              </div>
              <div
                class="absolute top-40 right-20 w-48 h-48 rounded-full bg-secondary/5 blur-3xl animate-float"
                style="animation-delay: 2s"
              >
              </div>
              <div
                class="absolute bottom-20 left-1/3 w-72 h-72 rounded-full bg-accent/4 blur-3xl animate-float"
                style="animation-delay: 4s"
              >
              </div>
            </div>

            <div class="max-w-6xl mx-auto px-4 py-20 sm:py-28 relative">
              <div class="text-center mb-14 sm:mb-20">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-medium mb-6">
                  <.icon name="hero-sparkles" class="w-3.5 h-3.5" />
                  <span>Data-driven comparison for everything</span>
                </div>
                <h1 class="text-5xl sm:text-7xl font-bold tracking-tight mb-4 leading-[1.1]">
                  anything.<br class="sm:hidden" /><span class="gradient-text-warm">compare</span>
                </h1>
                <p class="text-base sm:text-lg opacity-60 max-w-lg mx-auto leading-relaxed">
                  Side-by-side specs for phones, laptops, cameras — anything.
                  Pick a category to start comparing real data.
                </p>
              </div>

              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 max-w-4xl mx-auto">
                <%= for {cat, i} <- Enum.with_index(@categories) do %>
                  <.link
                    navigate={~p"/#{cat}"}
                    class="card card-lift card-glow bg-base-100/60 hover:bg-base-100 p-6 sm:p-8 rounded-2xl border border-base-300/50 block group relative"
                    style="animation: fade-in-up 0.4s ease-out #{i * 0.08}s both"
                  >
                    <div class="flex items-center gap-4 mb-3">
                      <div class="w-11 h-11 rounded-xl bg-gradient-to-br from-primary/20 to-secondary/20 flex items-center justify-center shadow-sm group-hover:shadow-md transition-all group-hover:scale-105">
                        <.icon name="hero-cube" class="w-5 h-5 text-primary" />
                      </div>
                      <div class="min-w-0">
                        <h2 class="text-lg sm:text-xl font-semibold capitalize tracking-tight">
                          {cat}
                        </h2>
                        <p class="text-xs opacity-50">
                          {AnythingCompare.Catalog.count_products(cat)} products
                        </p>
                      </div>
                    </div>
                    <div class="flex items-center gap-1.5 text-xs font-medium text-primary opacity-0 group-hover:opacity-100 transition-all translate-x-[-4px] group-hover:translate-x-0">
                      Compare now <.icon name="hero-arrow-right" class="w-3 h-3" />
                    </div>
                  </.link>
                <% end %>
              </div>

              <div class="text-center mt-16 opacity-30 text-xs sm:text-sm">
                <span class="font-mono">Data contributed via GitHub</span>
              </div>
            </div>
          </div>
        <% else %>
          <%!-- Category page --%>
          <div class="max-w-7xl mx-auto px-4 py-6 sm:py-10">
            <%!-- Category header banner --%>
            <div class="rounded-2xl bg-gradient-to-br from-primary/5 via-secondary/5 to-accent/5 border border-base-300/50 p-6 sm:p-8 mb-8">
              <div class="flex items-center gap-2 mb-2">
                <.link
                  navigate={~p"/"}
                  class="text-xs opacity-40 hover:opacity-80 transition-opacity inline-flex items-center gap-1"
                >
                  <.icon name="hero-arrow-left" class="w-3 h-3" /> Home
                </.link>
                <span class="text-xs opacity-20">/</span>
                <span class="text-xs opacity-50 capitalize">{@category}</span>
              </div>
              <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div class="flex items-center gap-4">
                  <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-primary/20 to-secondary/20 flex items-center justify-center shadow-sm shrink-0">
                    <.icon name="hero-cube" class="w-6 h-6 text-primary" />
                  </div>
                  <div>
                    <h1 class="text-2xl sm:text-3xl font-bold capitalize tracking-tight">
                      {@category}
                    </h1>
                    <p class="text-sm opacity-50 mt-0.5">
                      {@product_count} product{if @product_count != 1, do: "s"}
                    </p>
                  </div>
                </div>
                <div class="flex items-center gap-2 sm:gap-3">
                  <select
                    phx-change="sort"
                    name="sort_by"
                    class="select select-bordered select-xs sm:select-sm text-xs sm:text-sm"
                  >
                    <option value="">Default order</option>
                    <%= for field <- @sortable_fields do %>
                      <%= if Map.has_key?(@schema, field) do %>
                        <option value={field} selected={@sort_by == field}>
                          By {@schema[field]["label"]}
                          <%= if @sort_by == field do %>
                            {(@sort_dir == :desc && "↓") || "↑"}
                          <% end %>
                        </option>
                      <% end %>
                    <% end %>
                  </select>
                </div>
              </div>
            </div>

            <%!-- Search and filters bar --%>
            <div class="flex flex-wrap items-center gap-2 sm:gap-3 mb-8">
              <label class="input input-bordered input-sm sm:input-md flex items-center gap-2 max-w-xs w-full sm:w-auto bg-base-100/80">
                <.icon name="hero-magnifying-glass" class="w-4 h-4 shrink-0 opacity-40" />
                <input
                  type="text"
                  placeholder="Search products or specs..."
                  value={@query}
                  phx-keyup="filter"
                  name="q"
                  class="grow outline-none bg-transparent text-xs sm:text-sm"
                />
              </label>

              <%= for field <- @filterable_fields do %>
                <% options = @filter_options[field] %>
                <%= if options && options.values != [] do %>
                  <select
                    phx-change="filter-field"
                    phx-value-field={field}
                    name="value"
                    class="select select-bordered select-xs sm:select-sm min-w-[100px] sm:min-w-[120px] text-xs sm:text-sm bg-base-100/80"
                  >
                    <option value="">{@schema[field]["label"]}</option>
                    <%= for val <- options.values do %>
                      <option value={val} selected={@active_filters[field] == val}>
                        {filter_value_label(field, val, @schema)}
                      </option>
                    <% end %>
                  </select>
                <% end %>
              <% end %>

              <%= if @active_filters != %{} do %>
                <button
                  phx-click="clear-filters"
                  class="btn btn-ghost btn-xs sm:btn-sm text-xs opacity-50 hover:opacity-100"
                >
                  Clear filters
                </button>
              <% end %>
            </div>

            <%= if MapSet.size(@selected_slugs) > 0 do %>
              <%!-- Compare selection bar --%>
              <div class="sticky top-4 z-30 mb-4">
                <div class="glass-panel rounded-xl px-4 py-3 flex items-center justify-between gap-3 shadow-lg">
                  <div class="flex items-center gap-2 text-sm">
                    <.icon name="hero-check-circle" class="w-5 h-5 text-primary" />
                    <span class="font-medium">
                      {MapSet.size(@selected_slugs)} {if MapSet.size(@selected_slugs) == 1,
                        do: "product",
                        else: "products"} selected
                    </span>
                  </div>
                  <div class="flex items-center gap-2">
                    <button
                      phx-click="compare-selected"
                      class="btn btn-primary btn-sm gap-1.5"
                    >
                      <.icon name="hero-arrows-right-left" class="w-4 h-4" /> Compare
                    </button>
                    <button
                      phx-click="clear-selection"
                      class="btn btn-ghost btn-sm text-xs opacity-60 hover:opacity-100"
                    >
                      Clear
                    </button>
                  </div>
                </div>
              </div>
            <% end %>

            <%= if @products == [] do %>
              <%!-- Empty state --%>
              <div class="text-center py-16 sm:py-24">
                <.icon name="hero-inbox" class="w-12 h-12 sm:w-16 sm:h-16 mx-auto mb-4 opacity-20" />
                <p class="text-lg sm:text-xl font-medium opacity-50">
                  No products found
                </p>
                <%= if @query != "" or @active_filters != %{} do %>
                  <p class="text-sm opacity-40 mt-1">
                    Try adjusting your search or filters
                  </p>
                  <button
                    phx-click="clear-filters"
                    class="btn btn-ghost btn-sm mt-4"
                  >
                    Clear all filters
                  </button>
                <% else %>
                  <p class="text-sm opacity-40 mt-1">
                    Add data at
                    <span class="font-mono">github.com/anything-compare/data/{@category}</span>
                  </p>
                <% end %>
              </div>
            <% else %>
              <%!-- Product grid --%>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3 sm:gap-4">
                <%= for product <- @products do %>
                  <% is_selected = product.slug in @selected_slugs %>
                  <.link
                    navigate={~p"/#{@category}/product/#{product.slug}"}
                    class={[
                      "card card-lift bg-base-100/60 hover:bg-base-100 p-4 sm:p-5 rounded-xl border block group relative transition-all duration-200",
                      is_selected && "border-primary/60 ring-1 ring-primary/30 bg-primary/[0.03]",
                      !is_selected && "border-base-300/50"
                    ]}
                  >
                    <div class="flex items-start justify-between mb-3">
                      <div class="min-w-0 flex-1">
                        <span class="text-[10px] uppercase tracking-wider font-medium text-primary/60">
                          {Map.get(product.specs, "brand", "")}
                        </span>
                        <h2 class="font-semibold text-sm sm:text-base leading-tight truncate mt-0.5">
                          {product.name}
                        </h2>
                      </div>
                      <div class="flex items-center gap-1.5 shrink-0 mt-0.5">
                        <div
                          phx-click="toggle-select"
                          phx-value-slug={product.slug}
                          phx-click-stop=""
                          class={[
                            "w-7 h-7 rounded-lg flex items-center justify-center cursor-pointer transition-all border",
                            is_selected && "bg-primary border-primary text-primary-content",
                            !is_selected &&
                              "border-base-300 hover:border-primary/50 bg-base-200/50 opacity-0 group-hover:opacity-100",
                            is_selected && "opacity-100"
                          ]}
                        >
                          <%= if is_selected do %>
                            <.icon name="hero-check" class="w-4 h-4" />
                          <% else %>
                            <.icon name="hero-plus" class="w-3.5 h-3.5 opacity-40" />
                          <% end %>
                        </div>
                        <div class="w-7 h-7 rounded-lg bg-gradient-to-br from-primary/10 to-secondary/10 flex items-center justify-center group-hover:scale-105 transition-transform">
                          <.icon
                            name="hero-chevron-right"
                            class="w-3.5 h-3.5 text-primary/40 group-hover:text-primary/70 transition-colors"
                          />
                        </div>
                      </div>
                    </div>

                    <div class="space-y-2 text-xs sm:text-sm border-t border-base-300/30 pt-3">
                      <%= for {spec_key, spec_meta} <- @preview_specs do %>
                        <% value = product.specs[spec_key] %>
                        <div class="flex items-center justify-between gap-2">
                          <span class="opacity-45 truncate">{spec_meta["label"]}</span>
                          <span class="font-semibold tabular-nums shrink-0 px-1.5 py-0.5 rounded-md bg-base-200/50 text-[11px]">
                            {render_spec_value(value, spec_meta)}
                          </span>
                        </div>
                        <%= if is_number(value) and spec_meta["visual"] == "bar" do %>
                          <div class="spec-bar-container h-1 -mt-1">
                            <div
                              class="h-full rounded-full bg-gradient-to-r from-primary/50 to-primary spec-bar"
                              style={"width: #{min(100, value)}%"}
                            />
                          </div>
                        <% end %>
                      <% end %>
                    </div>
                  </.link>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  def render_spec_value(nil, _meta), do: "—"
  def render_spec_value("", _meta), do: "—"

  def render_spec_value(value, %{"type" => "number", "unit" => unit}) when is_number(value) do
    "#{value}#{unit}"
  end

  def render_spec_value(value, %{"type" => "subjective"}) when is_list(value) do
    vals = Enum.map(value, & &1["numeric_value"]) |> Enum.reject(&is_nil/1)
    if vals == [], do: "—", else: "#{round(Enum.sum(vals) / length(vals))}%"
  end

  def render_spec_value(value, _meta) when is_binary(value), do: value
  def render_spec_value(value, _meta), do: "#{value}"
end
