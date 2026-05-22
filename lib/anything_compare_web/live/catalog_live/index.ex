defmodule AnythingCompareWeb.CatalogLive.Index do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand", "filterable" => true},
    "model" => %{"type" => "string", "label" => "Model", "filterable" => false},
    "battery_mah" => %{"type" => "number", "label" => "Battery", "unit" => "mAh", "visual" => "bar"},
    "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\"", "visual" => "bar"},
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB", "visual" => "bar"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB", "visual" => "bar"}
  }

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, current_category: current_category, selected_slugs: MapSet.new())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    query = params["q"] || ""

    socket = assign(socket, :page_title, page_title(category))

    socket =
      if category == "root" do
        categories = AnythingCompare.Catalog.list_categories()
        assign(socket, categories: categories, category: nil)
      else
        products = AnythingCompare.Cache.Storage.get_products(category)
        schema = AnythingCompare.Cache.Storage.get_schema(category)
        effective_schema = if schema == %{}, do: @sample_schema, else: schema

        filtered =
          if query == "" do
            products
          else
            Enum.filter(products, fn p ->
              String.contains?(String.downcase(p.name), String.downcase(query))
            end)
          end

        assign(socket,
          category: category,
          products: filtered,
          all_products: products,
          product_count: length(products),
          schema: effective_schema,
          query: query
        )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"q" => query}, socket) do
    category = socket.assigns.category
    products = socket.assigns.all_products || AnythingCompare.Cache.Storage.get_products(category)

    filtered =
      if query == "" do
        products
      else
        Enum.filter(products, fn p ->
          String.contains?(String.downcase(p.name), String.downcase(query))
        end)
      end

    {:noreply, assign(socket, products: filtered, query: query)}
  end

  @impl true
  def handle_event("toggle-select", %{"slug" => slug}, socket) do
    selected = socket.assigns.selected_slugs

    selected =
      if MapSet.member?(selected, slug) do
        MapSet.delete(selected, slug)
      else
        MapSet.put(selected, slug)
      end

    {:noreply, assign(socket, :selected_slugs, selected)}
  end

  @impl true
  def handle_event("compare-selected", _, socket) do
    slugs = MapSet.to_list(socket.assigns.selected_slugs)

    if length(slugs) >= 2 do
      category = socket.assigns.category
      url = ~p"/#{category}/compare/#{Enum.join(slugs, "-vs-")}"
      {:noreply, push_navigate(socket, to: url)}
    else
      {:noreply, socket}
    end
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <%= if @category == nil do %>
          <div class="max-w-6xl mx-auto px-4 py-16">
            <div class="text-center mb-12">
              <h1 class="text-5xl font-bold tracking-tight mb-3">
                anything.<span class="text-primary">compare</span>
              </h1>
              <p class="text-lg opacity-70 max-w-xl mx-auto">
                Side-by-side specs for everything. Pick a category.
              </p>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <%= for cat <- @categories do %>
                <.link
                  navigate={~p"/#{cat}"}
                  class="card bg-base-200 hover:bg-base-300 transition-all duration-200 p-6 rounded-xl border border-base-300 block"
                >
                  <h2 class="text-xl font-semibold capitalize">{cat}</h2>
                  <p class="text-sm opacity-60 mt-1">
                    {AnythingCompare.Catalog.count_products(cat)} products
                  </p>
                </.link>
              <% end %>
            </div>

            <div class="text-center mt-16 opacity-50 text-sm">
              Contribute data at <span class="font-mono">github.com/anything-compare/data</span>
            </div>
          </div>
        <% else %>
          <div class="max-w-7xl mx-auto px-4 py-8">
            <div class="flex items-center justify-between mb-8">
              <div>
                <h1 class="text-3xl font-bold capitalize">{@category}</h1>
                <p class="text-sm opacity-60">{@product_count} products</p>
              </div>

              <div class="flex items-center gap-4">
                <%= if MapSet.size(@selected_slugs) >= 2 do %>
                  <button phx-click="compare-selected" class="btn btn-primary btn-sm">
                    Compare {MapSet.size(@selected_slugs)} Selected
                  </button>
                <% end %>
                <label class="join items-center gap-2 input input-bordered input-sm">
                  <.icon name="hero-magnifying-glass" class="w-4 h-4 opacity-40" />
                  <input
                    type="text"
                    placeholder="Filter products..."
                    value={@query}
                    phx-keyup="filter"
                    name="q"
                    class="grow outline-none bg-transparent"
                  />
                </label>
              </div>
            </div>

            <%= if @products == [] do %>
              <div class="text-center py-24 opacity-50">
                <p class="text-lg">No products yet</p>
                <p class="text-sm mt-2">Add data to get started</p>
              </div>
            <% else %>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                <%= for product <- @products do %>
                  <div class={[
                    "card bg-base-200 hover:bg-base-300 transition-all duration-200 p-5 rounded-xl border block relative",
                    if(MapSet.member?(@selected_slugs, product.slug), do: "border-primary ring-2 ring-primary/20", else: "border-base-300")
                  ]}>
                    <button
                      phx-click="toggle-select"
                      phx-value-slug={product.slug}
                      class={[
                        "absolute top-3 right-3 w-5 h-5 rounded border-2 flex items-center justify-center transition-colors",
                        if(MapSet.member?(@selected_slugs, product.slug),
                          do: "bg-primary border-primary text-primary-content",
                          else: "border-base-content/30 hover:border-base-content/60"
                        )
                      ]}
                    >
                      <%= if MapSet.member?(@selected_slugs, product.slug) do %>
                        <.icon name="hero-check" class="w-3 h-3" />
                      <% end %>
                    </button>

                    <.link navigate={~p"/#{@category}/product/#{product.slug}"} class="block">
                      <h2 class="font-semibold text-lg pr-6">{product.name}</h2>
                      <div class="mt-3 space-y-1.5 text-sm">
                        <%= for {key, meta} <- Enum.take(@schema, 4) do %>
                          <div class="flex justify-between">
                            <span class="opacity-60">{meta["label"]}</span>
                            <span class="font-medium">
                              {render_spec_value(product.specs[key], meta)}
                            </span>
                          </div>
                        <% end %>
                      </div>
                    </.link>
                  </div>
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
