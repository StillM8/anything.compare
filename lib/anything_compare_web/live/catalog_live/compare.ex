defmodule AnythingCompareWeb.CatalogLive.Compare do
  use AnythingCompareWeb, :live_view

  @sample_schema %{
    "brand" => %{"type" => "string", "label" => "Brand", "filterable" => true},
    "model" => %{"type" => "string", "label" => "Model", "filterable" => false},
    "battery_mah" => %{"type" => "number", "label" => "Battery", "unit" => "mAh"},
    "display_size" => %{"type" => "number", "label" => "Display", "unit" => "\""},
    "ram_gb" => %{"type" => "number", "label" => "RAM", "unit" => "GB"},
    "storage_gb" => %{"type" => "number", "label" => "Storage", "unit" => "GB"}
  }

  # TODO: Screen size visualization — render a scaled bezel + notch diagram
  # beside display_size in the compare matrix. Use a small CSS-drawn phone
  # outline where the screen area fills proportionally. Also show physical
  # dimensions (height, width, thickness, weight) as a grouped "Physical" row.

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"
    {:ok, assign(socket, current_category: current_category, show_add_dropdown: false)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    slugs_param = params["slugs"] || ""
    slug_list = String.split(slugs_param, "-vs-") |> Enum.reject(&(&1 == ""))

    all_products = AnythingCompare.Cache.Storage.get_products(category)
    products = Enum.filter(all_products, &(&1.slug in slug_list))
    schema = AnythingCompare.Cache.Storage.get_schema(category)
    effective_schema = if schema == %{}, do: @sample_schema, else: schema
    names = Enum.map(products, & &1.name)

    avail = Enum.reject(all_products, &(&1.slug in slug_list))

    {:noreply,
     assign(socket,
       category: category,
       products: products,
       all_products: all_products,
       available: avail,
       slugs: slug_list,
       schema: effective_schema,
       page_title: Enum.join(names, " vs "),
       show_add_dropdown: false
     )}
  end

  @impl true
  def handle_event("toggle-add", _, socket) do
    {:noreply, assign(socket, :show_add_dropdown, not socket.assigns.show_add_dropdown)}
  end

  @impl true
  def handle_event("add-product", %{"slug" => slug}, socket) do
    new_slugs = socket.assigns.slugs ++ [slug]
    url = ~p"/#{socket.assigns.category}/compare/#{Enum.join(new_slugs, "-vs-")}"
    {:noreply, push_patch(socket, to: url)}
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

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
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
          </div>

          <%= if @products == [] do %>
            <div class="text-center py-24 opacity-50">
              <p class="text-lg">No products found</p>
            </div>
          <% else %>
            <div class="relative overflow-x-auto rounded-xl border border-base-300 bg-base-100 shadow-sm">
              <table class="w-full text-sm">
                <thead>
                  <tr class="bg-base-200">
                    <th class="sticky left-0 z-10 bg-base-200 px-4 py-3 text-left font-semibold min-w-[160px]">
                      Spec
                    </th>
                    <%= for product <- @products do %>
                      <th class="px-3 py-3 text-left font-semibold min-w-[160px] relative group">
                        <div class="flex items-center justify-between gap-1">
                          <span class="text-base leading-tight">{product.name}</span>
                          <button phx-click="remove-product" phx-value-slug={product.slug} class="btn btn-ghost btn-xs p-0.5 opacity-0 group-hover:opacity-100 transition-opacity text-error shrink-0">
                            <.icon name="hero-x-mark" class="w-3.5 h-3.5" />
                          </button>
                        </div>
                        <.link navigate={~p"/#{@category}/product/#{product.slug}"} class="text-[11px] opacity-50 hover:opacity-100">
                          Details →
                        </.link>
                      </th>
                    <% end %>
                    <th class="px-3 py-3 text-left min-w-[80px] w-[80px] relative">
                      <button
                        phx-click="toggle-add"
                        class="btn btn-ghost btn-sm w-full flex items-center justify-center gap-1 text-base-content/40 hover:text-base-content/70 transition-colors"
                      >
                        <.icon name="hero-plus" class="w-5 h-5" />
                        <span class="text-xs">Add</span>
                      </button>

                      <%= if @show_add_dropdown do %>
                        <div class="absolute top-full right-0 mt-1 z-50 w-56 bg-base-100 border border-base-300 rounded-xl shadow-xl overflow-hidden">
                          <div class="p-2 text-xs font-semibold opacity-50 px-3 pt-3 pb-1">
                            Add to compare
                          </div>
                          <%= if @available == [] do %>
                            <div class="px-3 py-4 text-xs opacity-40 text-center">
                              All products added
                            </div>
                          <% else %>
                            <%= for avail <- @available do %>
                              <button
                                phx-click="add-product"
                                phx-value-slug={avail.slug}
                                class="w-full text-left px-3 py-2 text-sm hover:bg-base-200 transition-colors flex items-center gap-2"
                              >
                                <.icon name="hero-plus-circle" class="w-4 h-4 shrink-0 opacity-40" />
                                {avail.name}
                              </button>
                            <% end %>
                          <% end %>
                        </div>
                      <% end %>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <%= for {spec_key, spec_meta} <- @schema do %>
                    <tr class="border-t border-base-300">
                      <td class="sticky left-0 z-10 bg-base-100 px-4 py-3 font-medium whitespace-nowrap">
                        <div class="flex items-center gap-2">
                          <span>{spec_meta["label"]}</span>
                          <span class="text-xs opacity-40">{spec_meta["unit"]}</span>
                        </div>
                      </td>
                      <%= for product <- @products do %>
                        <td class="px-4 py-3">
                          {spec_value(product.specs[spec_key], spec_meta)}
                        </td>
                      <% end %>
                      <td class="px-4 py-3 text-center opacity-20">—</td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>

            <div class="mt-4 text-xs opacity-40 text-center">
              Hover over a name to remove it
              <span class="mx-2">·</span>
              Click <strong>+ Add</strong> to include another product
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp spec_value(nil, _meta), do: "—"
  defp spec_value("", _meta), do: "—"

  defp spec_value(value, %{"type" => "number", "unit" => unit}) when is_number(value) do
    "#{value}#{unit}"
  end

  defp spec_value(value, %{"type" => "subjective"}) when is_list(value) do
    vals = Enum.map(value, & &1["numeric_value"]) |> Enum.reject(&is_nil/1)
    if vals == [], do: "—", else: "#{round(Enum.sum(vals) / length(vals))}%"
  end

  defp spec_value(value, _meta) when is_binary(value), do: value
  defp spec_value(value, _meta), do: "#{value}"
end
