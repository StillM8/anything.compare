defmodule AnythingCompareWeb.CatalogLive.Compare do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand", "filterable" => true},
    "model" => %{"type" => "string", "label" => "Model", "filterable" => false},
    "battery_mah" => %{"type" => "number", "label" => "Battery", "unit" => "mAh", "visual" => "bar"},
    "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\"", "visual" => "bar"},
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB", "visual" => "bar"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB", "visual" => "bar"}
  }

  # TODO: Screen size visualization — render a scaled bezel + notch diagram
  # beside display_size in the compare matrix. Use a small CSS-drawn phone
  # outline where the screen area fills proportionally. Also show physical
  # dimensions (height, width, thickness, weight) as a grouped "Physical" row.

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, current_category: current_category, show_diff: false)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    slugs_param = params["slugs"] || ""
    slug_list = String.split(slugs_param, "-vs-") |> Enum.reject(&(&1 == ""))

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

  @impl true
  def handle_event("remove-product", %{"slug" => slug}, socket) do
    remaining = Enum.reject(socket.assigns.slugs, &(&1 == slug))

    if length(remaining) >= 2 do
      url = ~p"/#{socket.assigns.category}/compare/#{Enum.join(remaining, "-vs-")}"
      {:noreply, push_patch(socket, to: url)}
    else
      {:noreply, push_navigate(socket, to: ~p"/#{socket.assigns.category}")}
    end
  end

  @impl true
  def handle_event("move-product", %{"slug" => slug, "direction" => dir}, socket) do
    slugs = socket.assigns.slugs
    idx = Enum.find_index(slugs, &(&1 == slug))

    new_slugs =
      case dir do
        "left" when idx > 0 -> List.replace_at(slugs, idx, Enum.at(slugs, idx - 1)) |> List.replace_at(idx - 1, slug)
        "right" when idx < length(slugs) - 1 -> List.replace_at(slugs, idx, Enum.at(slugs, idx + 1)) |> List.replace_at(idx + 1, slug)
        _ -> slugs
      end

    if new_slugs != slugs do
      url = ~p"/#{socket.assigns.category}/compare/#{Enum.join(new_slugs, "-vs-")}"
      {:noreply, push_patch(socket, to: url)}
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

  defp divergent?(products, spec_key) do
    products
    |> Enum.map(fn p -> p.specs[spec_key] end)
    |> Enum.uniq()
    |> length() > 1
  end

  defp diff_badge(assigns) do
    ~H"""
    <span class="text-[10px] font-semibold uppercase tracking-wider text-warning px-1.5 py-0.5 rounded-full bg-warning/15">
      Diff
    </span>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <div class="max-w-full mx-auto px-4 py-8">
          <div class="flex items-center justify-between mb-6">
            <div>
              <.link navigate={~p"/#{@category}"} class="text-sm opacity-60 hover:opacity-100 transition-opacity">
                ← Back to {@category}
              </.link>
              <h1 class="text-2xl font-bold mt-1">
                Comparing {length(@products)} items
              </h1>
            </div>

            <div class="flex items-center gap-3">
              <button
                phx-click="toggle-diff"
                class={[
                  "btn btn-sm transition-all duration-200",
                  @show_diff && "btn-warning"
                ]}
              >
                <.icon name="hero-adjustments-horizontal" class="w-4 h-4" />
                {@show_diff && "Hide Differences" || "Highlight Differences"}
              </button>
            </div>
          </div>

          <%= if @products == [] do %>
            <div class="text-center py-24 opacity-50">
              <p class="text-lg">No products found for this comparison</p>
            </div>
          <% else %>
            <div class="relative overflow-x-auto rounded-xl border border-base-300 bg-base-100 shadow-sm">
              <table class="w-full text-sm">
                <thead>
                  <tr class="bg-base-200">
                    <th class="sticky left-0 z-10 bg-base-200 px-4 py-3 text-left font-semibold min-w-[160px]">
                      Spec
                    </th>
                    <%= for {product, i} <- Enum.with_index(@products) do %>
                      <th class="px-3 py-3 text-left font-semibold min-w-[160px] relative group">
                        <div class="flex flex-col gap-1">
                          <div class="flex items-center justify-between">
                            <span class="text-base leading-tight">{product.name}</span>
                            <div class="flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity">
                              <%= if i > 0 do %>
                                <button phx-click="move-product" phx-value-slug={product.slug} phx-value-direction="left" class="btn btn-ghost btn-xs p-0.5">
                                  <.icon name="hero-chevron-left" class="w-3 h-3" />
                                </button>
                              <% end %>
                              <%= if i < length(@products) - 1 do %>
                                <button phx-click="move-product" phx-value-slug={product.slug} phx-value-direction="right" class="btn btn-ghost btn-xs p-0.5">
                                  <.icon name="hero-chevron-right" class="w-3 h-3" />
                                </button>
                              <% end %>
                              <button phx-click="remove-product" phx-value-slug={product.slug} class="btn btn-ghost btn-xs p-0.5 text-error hover:text-error">
                                <.icon name="hero-x-mark" class="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </div>
                          <.link navigate={~p"/#{@category}/product/#{product.slug}"} class="text-[11px] opacity-50 hover:opacity-100">
                            Details →
                          </.link>
                        </div>
                      </th>
                    <% end %>
                  </tr>
                </thead>
                <tbody>
                  <%= for {spec_key, spec_meta} <- @schema do %>
                    <% is_diff = @show_diff && divergent?(@products, spec_key) %>
                    <tr class={[
                      "border-t border-base-300 transition-colors duration-200",
                      is_diff && "bg-warning/[0.04]"
                    ]}>
                      <td class={[
                        "sticky left-0 z-10 px-4 py-3 font-medium whitespace-nowrap",
                        if(is_diff, do: "bg-warning/[0.06]", else: "bg-base-100")
                      ]}>
                        <div class="flex items-center gap-2">
                          <span>{spec_meta["label"]}</span>
                          <span class="text-xs opacity-40">{spec_meta["unit"]}</span>
                          <%= if is_diff do %>
                            <.diff_badge />
                          <% end %>
                        </div>
                      </td>
                      <%= for product <- @products do %>
                        <td class={[
                          "px-4 py-3 transition-colors duration-200",
                          is_diff && "bg-warning/[0.04]"
                        ]}>
                          <.spec_cell value={product.specs[spec_key]} meta={spec_meta} />
                        </td>
                      <% end %>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>

            <div class="mt-4 text-xs opacity-40 text-center">
              Hover over a product name to reorder or remove items
              <span class="mx-2">·</span>
              <span>Click "Highlight Differences" to see where specs diverge</span>
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
            <div class="h-full bg-secondary transition-all duration-500 rounded-full" style={"width: #{@cell_pct}%"}></div>
          </div>
          <span class="font-medium tabular-nums text-sm">{@cell_pct}%</span>
          <span class="text-xs opacity-40">({@cell_src_count} sources)</span>
        </div>
      <% :number_bar -> %>
        <div class="flex items-center gap-2">
          <div class="flex-1 h-2 bg-base-300 rounded-full overflow-hidden">
            <div class="h-full bg-primary transition-all duration-500 rounded-full" style={"width: #{@cell_pct}%"}></div>
          </div>
          <span class="font-medium tabular-nums text-sm">{@cell_num}{@cell_unit}</span>
        </div>
      <% _ -> %>
        {@cell}
    <% end %>
    """
  end
end
