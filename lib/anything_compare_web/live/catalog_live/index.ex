defmodule AnythingCompareWeb.CatalogLive.Index do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand"},
    "model" => %{"type" => "string", "label" => "Model"},
    "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\""},
    "resolution" => %{"type" => "string", "label" => "Resolution"},
    "refresh_rate" => %{"type" => "number", "label" => "Refresh Rate", "unit" => "Hz"},
    "processor" => %{"type" => "string", "label" => "Processor"},
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB"},
    "battery_mah" => %{"type" => "number", "label" => "Battery", "unit" => "mAh"},
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
    "stability" => %{"type" => "subjective", "label" => "Stability"}
  }

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, current_category: current_category)}
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

              <label class="input input-bordered input-sm flex items-center gap-2 max-w-xs">
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

            <%= if @products == [] do %>
              <div class="text-center py-24 opacity-50">
                <p class="text-lg">No products yet</p>
                <p class="text-sm mt-2">Add data to get started</p>
              </div>
            <% else %>
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                <%= for product <- @products do %>
                  <.link
                    navigate={~p"/#{@category}/product/#{product.slug}"}
                    class="card bg-base-200 hover:bg-base-300 transition-all duration-200 p-5 rounded-xl border border-base-300 block relative"
                  >
                    <h2 class="font-semibold text-lg">{product.name}</h2>
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
