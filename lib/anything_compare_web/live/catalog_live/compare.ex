defmodule AnythingCompareWeb.CatalogLive.Compare do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand", "filterable" => true},
    "model" => %{"type" => "string", "label" => "Model", "filterable" => false},
    "battery_mah" => %{
      "type" => "number",
      "label" => "Battery",
      "unit" => "mAh",
      "visual" => "bar"
    },
    "display_size" => %{
      "type" => "number",
      "label" => "Display",
      "unit" => "\"",
      "visual" => "bar"
    },
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB", "visual" => "bar"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB", "visual" => "bar"}
  }

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, current_category: current_category, show_diff: false)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    slugs_param = params["slugs"] || ""
    slug_list = String.split(slugs_param, "-vs-")

    products = AnythingCompare.Cache.Storage.get_products_for_comparison(category, slug_list)
    schema = AnythingCompare.Cache.Storage.get_schema(category)
    effective_schema = if schema == %{}, do: @sample_schema, else: schema

    names = Enum.map(products, & &1.name)

    {:noreply,
     assign(socket,
       category: category,
       products: products,
       slugs: slug_list,
       schema: effective_schema,
       page_title: Enum.join(names, " vs "),
       show_diff: false
     )}
  end

  @impl true
  def handle_event("toggle-diff", _, socket) do
    {:noreply, assign(socket, :show_diff, not socket.assigns.show_diff)}
  end

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
  end

  defp divergent?(products, spec_key) do
    products
    |> Enum.map(fn p -> Map.get(p.specs, spec_key) end)
    |> Enum.uniq()
    |> length() > 1
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <div class="max-w-full mx-auto px-4 py-8">
          <div class="flex items-center justify-between mb-6">
            <div>
              <.link
                navigate={~p"/#{@category}"}
                class="text-sm opacity-60 hover:opacity-100 transition-opacity"
              >
                ← Back to {@category}
              </.link>
              <h1 class="text-2xl font-bold mt-1">Compare</h1>
            </div>

            <button
              phx-click="toggle-diff"
              class={[
                "btn btn-sm transition-all duration-200",
                @show_diff && "btn-warning"
              ]}
            >
              <.icon name="hero-adjustments-horizontal" class="w-4 h-4" />
              {(@show_diff && "Hide Differences") || "Highlight Differences"}
            </button>
          </div>

          <div class="relative overflow-x-auto rounded-xl border border-base-300 bg-base-100">
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-base-200">
                  <th class="sticky left-0 z-10 bg-base-200 px-4 py-3 text-left font-semibold min-w-[160px]">
                    Spec
                  </th>
                  <%= for product <- @products do %>
                    <th class="px-4 py-3 text-left font-semibold min-w-[140px]">
                      <div class="flex flex-col">
                        <span class="text-base">{product.name}</span>
                        <.link
                          navigate={~p"/#{@category}/product/#{product.slug}"}
                          class="text-xs opacity-50 hover:opacity-100"
                        >
                          Details →
                        </.link>
                      </div>
                    </th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <%= for {spec_key, spec_meta} <- @schema do %>
                  <tr class={[
                    "border-t border-base-300 transition-colors duration-200",
                    @show_diff && divergent?(@products, spec_key) && "bg-warning/10"
                  ]}>
                    <td class="sticky left-0 z-10 bg-base-100 px-4 py-3 font-medium whitespace-nowrap">
                      <div class="flex items-center gap-2">
                        <span>{spec_meta["label"]}</span>
                        <span class="text-xs opacity-40">{spec_meta["unit"]}</span>
                      </div>
                    </td>
                    <%= for product <- @products do %>
                      <td class="px-4 py-3">
                        <.spec_cell value={product.specs[spec_key]} meta={spec_meta} />
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <%= if @products == [] do %>
            <div class="text-center py-24 opacity-50">
              <p class="text-lg">No products found for this comparison</p>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def spec_cell(assigns) do
    value = assigns.value
    meta = assigns.meta

    assigns =
      cond do
        is_nil(value) or value == "" ->
          assign(assigns, :cell, "—")

        is_list(value) ->
          vals = Enum.map(value, & &1["numeric_value"]) |> Enum.reject(&is_nil/1)

          if vals == [] do
            assign(assigns, :cell, "—")
          else
            pct = round(Enum.sum(vals) / length(vals))
            src_count = length(vals)

            assigns
            |> assign(:cell_pct, pct)
            |> assign(:cell_src_count, src_count)
            |> assign(:cell_template, :subjective_bar)
          end

        is_number(value) and meta["visual"] == "bar" ->
          max_val =
            case meta["unit"] do
              "mAh" -> 6000
              "\"" -> 7.5
              "GB" -> 32
              _ -> 100
            end

          pct = min(value / max_val * 100, 100) |> round()
          unit = Map.get(meta, "unit", "")

          assigns
          |> assign(:cell_num, value)
          |> assign(:cell_unit, unit)
          |> assign(:cell_pct, pct)
          |> assign(:cell_template, :number_bar)

        is_number(value) ->
          unit = Map.get(meta, "unit", "")
          assign(assigns, :cell, "#{value}#{unit}")

        true ->
          assign(assigns, :cell, "#{value}")
      end

    ~H"""
    <%= case assigns[:cell_template] do %>
      <% :subjective_bar -> %>
        <div class="flex items-center gap-2">
          <div class="flex-1 h-2 bg-base-300 rounded-full overflow-hidden">
            <div
              class="h-full bg-secondary transition-all duration-500 rounded-full"
              style={"width: #{@cell_pct}%"}
            >
            </div>
          </div>
          <span class="font-medium tabular-nums text-sm">{@cell_pct}%</span>
          <span class="text-xs opacity-40">({@cell_src_count} sources)</span>
        </div>
      <% :number_bar -> %>
        <div class="flex items-center gap-2">
          <div class="flex-1 h-2 bg-base-300 rounded-full overflow-hidden">
            <div
              class="h-full bg-primary transition-all duration-500 rounded-full"
              style={"width: #{@cell_pct}%"}
            >
            </div>
          </div>
          <span class="font-medium tabular-nums text-sm">{@cell_num}{@cell_unit}</span>
        </div>
      <% _ -> %>
        {@cell}
    <% end %>
    """
  end
end
