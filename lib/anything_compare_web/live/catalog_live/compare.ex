defmodule AnythingCompareWeb.CatalogLive.Compare do
  use AnythingCompareWeb, :live_view

  @spec_order ~w(
    brand model display_size ram_gb storage_gb battery_mah os stability
  )

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

    {:ok,
     assign(socket,
       current_category: current_category,
       show_add_dropdown: false,
       swap_slug: nil
     )}
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

    ordered_schema = order_schema(effective_schema)

    avail = Enum.reject(all_products, &(&1.slug in slug_list))

    {:noreply,
     assign(socket,
       category: category,
       products: products,
       all_products: all_products,
       available: avail,
       slugs: slug_list,
       schema: ordered_schema,
       page_title: Enum.join(names, " vs "),
       show_add_dropdown: false,
       swap_slug: nil
     )}
  end

  @impl true
  def handle_event("toggle-add", _, socket) do
    {:noreply, assign(socket, show_add_dropdown: not socket.assigns.show_add_dropdown, swap_slug: nil)}
  end

  @impl true
  def handle_event("close-add", _, socket) do
    {:noreply, assign(socket, :show_add_dropdown, false)}
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

  @impl true
  def handle_event("toggle-swap", %{"slug" => slug}, socket) do
    current = socket.assigns.swap_slug
    {:noreply, assign(socket, :swap_slug, if(current == slug, do: nil, else: slug))}
  end

  @impl true
  def handle_event("close-swap", _, socket) do
    {:noreply, assign(socket, :swap_slug, nil)}
  end

  @impl true
  def handle_event(
        "swap-product",
        %{"current" => current_slug, "replacement" => replacement_slug},
        socket
      ) do
    new_slugs =
      Enum.map(socket.assigns.slugs, fn s ->
        if s == current_slug, do: replacement_slug, else: s
      end)

    url = ~p"/#{socket.assigns.category}/compare/#{Enum.join(new_slugs, "-vs-")}"
    {:noreply, push_patch(socket, to: url)}
  end

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
  end

  defp order_schema(schema) do
    @spec_order
    |> Enum.map(fn key -> {key, schema[key]} end)
    |> Enum.filter(fn {_, v} -> v != nil end)
  end

  defp swap_candidates(all_products, current_slug) do
    Enum.reject(all_products, &(&1.slug == current_slug))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <div class="max-w-full mx-auto px-2 sm:px-4 py-3 sm:py-8">
          <div class="flex items-center justify-between mb-4 sm:mb-6">
            <div>
              <.link
                navigate={~p"/#{@category}"}
                class="text-xs sm:text-sm opacity-60 hover:opacity-100 transition-opacity"
              >
                ← Back to {@category}
              </.link>
              <h1 class="text-base sm:text-2xl font-bold mt-0.5 sm:mt-1">
                Comparing {length(@products)} items
              </h1>
            </div>
          </div>

          <%= if @products == [] do %>
            <div class="text-center py-24 opacity-50">
              <p class="text-lg">No products found</p>
            </div>
          <% else %>
            <div class="rounded-xl border border-base-300 bg-base-100 shadow-sm">
              <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead>
                  <tr class="bg-base-200">
                    <th class="sticky left-0 z-10 bg-base-200 px-2 sm:px-4 py-2 sm:py-3 text-left font-semibold min-w-[110px] sm:min-w-[160px] text-xs sm:text-sm">
                      Spec
                    </th>
                    <%= for product <- @products do %>
                      <th class="px-2 sm:px-3 py-2 sm:py-3 text-left font-semibold min-w-[120px] sm:min-w-[170px] relative group">
                        <div class="flex items-center justify-between gap-1 mb-1">
                          <button
                            id={"swap-btn-#{product.slug}"}
                            phx-click="toggle-swap"
                            phx-value-slug={product.slug}
                            class="text-xs sm:text-base leading-tight font-semibold text-left hover:text-primary transition-colors flex items-center gap-1 truncate max-w-[90px] sm:max-w-none"
                          >
                            {product.name}
                            <.icon name="hero-chevron-down" class="w-2.5 h-2.5 sm:w-3 sm:h-3 shrink-0 opacity-40" />
                          </button>
                          <button
                            phx-click="remove-product"
                            phx-value-slug={product.slug}
                            class="btn btn-ghost btn-xs p-0.5 opacity-0 group-hover:opacity-100 transition-opacity text-error shrink-0"
                          >
                            <.icon name="hero-x-mark" class="w-3 h-3 sm:w-3.5 sm:h-3.5" />
                          </button>
                        </div>
                        <.link
                          navigate={~p"/#{@category}/product/#{product.slug}"}
                          class="text-[10px] sm:text-[11px] opacity-50 hover:opacity-100"
                        >
                          Details →
                        </.link>
                      </th>
                    <% end %>
                    <th class="px-1 sm:px-3 py-2 sm:py-3 text-left min-w-[52px] w-[52px] sm:min-w-[100px] sm:w-[100px]">
                      <button
                        id="add-btn"
                        phx-click="toggle-add"
                        class="btn btn-ghost btn-xs sm:btn-sm w-full flex items-center justify-center gap-0.5 sm:gap-1 text-base-content/40 hover:text-base-content/70 transition-colors"
                      >
                        <.icon name="hero-plus" class="w-4 h-4 sm:w-5 sm:h-5" />
                        <span class="text-[10px] sm:text-xs">Add</span>
                      </button>
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <%= for {spec_key, spec_meta} <- @schema do %>
                    <tr class="border-t border-base-300">
                      <td class="sticky left-0 z-10 bg-base-100 px-2 sm:px-4 py-2 sm:py-3 font-medium whitespace-nowrap text-xs sm:text-sm">
                        <div class="flex items-center gap-1 sm:gap-2">
                          <span>{spec_meta["label"]}</span>
                          <span class="text-[10px] sm:text-xs opacity-40">{spec_meta["unit"]}</span>
                        </div>
                      </td>
                      <%= for product <- @products do %>
                        <td class="px-2 sm:px-4 py-2 sm:py-3 text-xs sm:text-sm">
                          {spec_value(product.specs[spec_key], spec_meta)}
                        </td>
                      <% end %>
                      <td class="px-2 sm:px-4 py-2 sm:py-3 text-center opacity-20 text-xs sm:text-sm">—</td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
              </div>
            </div>

            <%!-- floating swap dropdown — rendered outside overflow container --%>
            <%= if @swap_slug do %>
              <div
                id="swap-dropdown"
                phx-click-away="close-swap"
                class="fixed z-50 w-56 sm:w-64"
                phx-hook=".PositionSwap"
                data-slug={@swap_slug}
              >
                <div class="bg-base-100 border border-base-300 rounded-xl shadow-xl overflow-hidden">
                  <div class="p-2 border-b border-base-200">
                    <label class="input input-bordered input-xs sm:input-sm flex items-center gap-1 sm:gap-2">
                      <.icon name="hero-magnifying-glass" class="w-3 h-3 sm:w-4 sm:h-4 shrink-0 opacity-40" />
                      <input
                        type="text"
                        id="swap-search-input"
                        placeholder="Search..."
                        class="grow outline-none bg-transparent text-xs sm:text-sm"
                      />
                    </label>
                  </div>
                  <div class="max-h-56 overflow-y-auto" id="swap-search-results">
                    <%= for candidate <- swap_candidates(@all_products, @swap_slug) do %>
                      <button
                        phx-click="swap-product"
                        phx-value-current={@swap_slug}
                        phx-value-replacement={candidate.slug}
                        data-name={candidate.name}
                        class="w-full text-left px-3 py-2 text-sm hover:bg-base-200 transition-colors flex items-center gap-2"
                      >
                        <.icon name="hero-swap" class="w-4 h-4 shrink-0 opacity-40" />
                        {candidate.name}
                      </button>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>

            <%!-- floating add dropdown — rendered outside overflow container --%>
            <%= if @show_add_dropdown do %>
              <div
                id="add-dropdown"
                phx-click-away="close-add"
                class="fixed z-50 w-56 sm:w-64"
                phx-hook=".PositionAdd"
              >
                <div class="bg-base-100 border border-base-300 rounded-xl shadow-xl overflow-hidden">
                  <div class="p-2">
                    <label class="input input-bordered input-sm flex items-center gap-2">
                      <.icon name="hero-magnifying-glass" class="w-4 h-4 shrink-0 opacity-40" />
                      <input
                        type="text"
                        id="add-search-input"
                        placeholder="Search models..."
                        class="grow outline-none bg-transparent text-sm"
                      />
                    </label>
                  </div>
                  <div class="max-h-64 overflow-y-auto" id="add-search-results">
                    <%= if @available == [] do %>
                      <div class="px-3 py-4 text-xs opacity-40 text-center">
                        All products added
                      </div>
                    <% else %>
                      <%= for avail <- @available do %>
                        <button
                          phx-click="add-product"
                          phx-value-slug={avail.slug}
                          data-name={avail.name}
                          class="w-full text-left px-3 py-2 text-sm hover:bg-base-200 transition-colors flex items-center gap-2"
                        >
                          <.icon name="hero-plus-circle" class="w-4 h-4 shrink-0 opacity-40" />
                          <span>{avail.name}</span>
                        </button>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>

            <div class="mt-3 sm:mt-4 text-[10px] sm:text-xs opacity-40 text-center">
              Tap name to switch models <span class="hidden sm:inline mx-2">·</span>
              <span class="sm:hidden block mt-1" />X to remove <span class="mx-2">·</span>
              <strong>+ Add</strong> another
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".PositionSwap">
      export default {
        mounted() {
          let slug = this.el.getAttribute("data-slug")
          let btn = document.getElementById("swap-btn-" + slug)
          if (btn) {
            let rect = btn.getBoundingClientRect()
            let w = this.el.offsetWidth || 224
            this.el.style.top = (rect.bottom + 4) + "px"
            this.el.style.left = Math.max(4, Math.min(rect.left, window.innerWidth - w - 4)) + "px"
          }
          this.input = document.getElementById("swap-search-input")
          this.results = document.getElementById("swap-search-results")
          if (this.input && this.results) {
            this.input.addEventListener("input", () => {
              let q = this.input.value.toLowerCase()
              for (let btn of this.results.querySelectorAll("button")) {
                let name = (btn.getAttribute("data-name") || "").toLowerCase()
                btn.style.display = name.includes(q) ? "" : "none"
              }
            })
          }
        }
      }
    </script>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".PositionAdd">
      export default {
        mounted() {
          let btn = document.getElementById("add-btn")
          if (btn) {
            let rect = btn.getBoundingClientRect()
            let w = this.el.offsetWidth || 224
            this.el.style.top = (rect.bottom + 4) + "px"
            this.el.style.left = Math.max(4, rect.right - w) + "px"
          }
          this.input = document.getElementById("add-search-input")
          this.results = document.getElementById("add-search-results")
          if (this.input && this.results) {
            this.input.addEventListener("input", () => {
              let q = this.input.value.toLowerCase()
              for (let btn of this.results.querySelectorAll("button")) {
                let name = (btn.getAttribute("data-name") || "").toLowerCase()
                btn.style.display = name.includes(q) ? "" : "none"
              }
            })
          }
        }
      }
    </script>
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
