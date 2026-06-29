defmodule AnythingCompareWeb.CatalogLive.Compare do
  use AnythingCompareWeb, :live_view
  alias AnythingCompare.Comparisons

  @impl true
  def mount(_params, session, socket) do
    current_category = session["current_category"] || "root"

    {:ok,
     assign(socket,
       current_category: current_category,
       show_add_dropdown: false,
       swap_slug: nil,
       highlight_diffs: false,
       expanded_benchmarks: %{}
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

    effective_schema =
      if schema == %{} do
        Comparisons.derive_schema(all_products)
      else
        schema
      end

    names = Enum.map(products, & &1.name)

    ordered_schema = Comparisons.order_specs(effective_schema)
    grouped_schema = Comparisons.group_specs(ordered_schema)
    avail = Enum.reject(all_products, &(&1.slug in slug_list))
    diff_set = diff_specs(products)

    {:noreply,
     assign(socket,
       category: category,
       products: products,
       all_products: all_products,
       available: avail,
       slugs: slug_list,
       schema: ordered_schema,
       schema_map: effective_schema,
       diff_set: diff_set,
       grouped_schema: grouped_schema,
       page_title: Enum.join(names, " vs "),
       show_add_dropdown: false,
       swap_slug: nil,
       highlight_diffs: Map.get(socket.assigns, :highlight_diffs, false),
       expanded_benchmarks: %{}
     )}
  end

  @impl true
  def handle_event("toggle-add", _, socket) do
    {:noreply,
     assign(socket, show_add_dropdown: not socket.assigns.show_add_dropdown, swap_slug: nil)}
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

  @impl true
  def handle_event("toggle-benchmark", %{"key" => key}, socket) do
    current = Map.get(socket.assigns.expanded_benchmarks, key, false)

    {:noreply,
     assign(
       socket,
       :expanded_benchmarks,
       Map.put(socket.assigns.expanded_benchmarks, key, not current)
     )}
  end

  @impl true
  def handle_event("toggle-diffs", _, socket) do
    {:noreply, assign(socket, :highlight_diffs, not socket.assigns.highlight_diffs)}
  end

  defp resolve_category(assigns, params) do
    case assigns[:current_category] do
      "root" -> params["category"] || "root"
      nil -> params["category"] || "root"
      category -> category
    end
  end

  defp swap_candidates(all_products, current_slug) do
    Enum.reject(all_products, &(&1.slug == current_slug))
  end

  defp diff_specs(products) do
    Comparisons.diff_keys(products)
    |> MapSet.new()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_category}>
      <div class="min-h-screen">
        <div class="max-w-7xl mx-auto px-2 sm:px-6 py-3 sm:py-8">
          <%!-- Header --%>
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 mb-4 sm:mb-6">
            <div>
              <.link
                navigate={~p"/#{@category}"}
                class="text-xs sm:text-sm opacity-50 hover:opacity-100 transition-opacity inline-flex items-center gap-1"
              >
                <.icon name="hero-arrow-left" class="w-3 h-3" /> Back to {@category}
              </.link>
              <h1 class="text-lg sm:text-2xl font-bold mt-0.5">
                Comparing {length(@products)} {String.capitalize(@category || "products")}
              </h1>
            </div>

            <div class="flex items-center gap-2">
              <%!-- Highlight differences toggle --%>
              <button
                phx-click="toggle-diffs"
                class={[
                  "btn btn-sm",
                  @highlight_diffs && "btn-warning",
                  !@highlight_diffs && "btn-ghost"
                ]}
              >
                <.icon name="hero-adjustments-horizontal" class="w-4 h-4" />
                <span class="hidden sm:inline">
                  {if @highlight_diffs, do: "Differences On", else: "Highlight Diffs"}
                </span>
              </button>
            </div>
          </div>

          <%= if @products == [] do %>
            <div class="text-center py-24 opacity-40">
              <.icon name="hero-arrows-right-left" class="w-12 h-12 mx-auto mb-4 opacity-30" />
              <p class="text-lg font-medium">Select products to compare</p>
              <p class="text-sm mt-1">Add products using the + button</p>
            </div>
          <% else %>
            <%!-- Toolbar --%>
            <div class="flex items-center gap-2 mb-3 text-xs sm:text-sm opacity-60">
              <.icon name="hero-information-circle" class="w-3.5 h-3.5" />
              <span>
                <%= if @highlight_diffs do %>
                  Rows where specs <strong>differ</strong> are highlighted
                <% else %>
                  Click a product name to swap · <strong>+</strong> to add · X to remove
                <% end %>
              </span>
            </div>

            <%!-- Comparison matrix --%>
            <div class="rounded-xl border border-base-300 bg-base-100 shadow-sm overflow-hidden">
              <div class="compare-scroll overflow-x-auto">
                <table class="w-full text-xs sm:text-sm">
                  <%!-- Table Header --%>
                  <thead>
                    <tr class="bg-base-200/80">
                      <th class="sticky left-0 z-10 bg-base-200/80 px-3 sm:px-4 py-2 sm:py-3 text-left font-semibold text-xs sm:text-sm min-w-[110px] sm:min-w-[150px]">
                        Specification
                      </th>
                      <%= for product <- @products do %>
                        <th class="px-2 sm:px-3 py-2 sm:py-3 text-left font-semibold min-w-[130px] sm:min-w-[180px] group relative">
                          <div class="flex items-center justify-between gap-1">
                            <div class="flex items-center gap-1.5 min-w-0">
                              <button
                                id={"swap-btn-#{product.slug}"}
                                phx-click="toggle-swap"
                                phx-value-slug={product.slug}
                                class="text-sm sm:text-base leading-tight font-semibold text-left hover:text-primary transition-colors truncate max-w-[90px] sm:max-w-[140px] cursor-pointer"
                              >
                                {product.name}
                              </button>
                              <.icon name="hero-chevron-down" class="w-3 h-3 shrink-0 opacity-30" />
                            </div>
                            <div class="flex items-center gap-0.5 shrink-0">
                              <.link
                                navigate={~p"/#{@category}/product/#{product.slug}"}
                                class="btn btn-ghost btn-xs px-1 opacity-0 group-hover:opacity-60 hover:opacity-100!"
                              >
                                <.icon name="hero-eye" class="w-3 h-3" />
                              </.link>
                              <button
                                phx-click="remove-product"
                                phx-value-slug={product.slug}
                                class="btn btn-ghost btn-xs px-1 opacity-0 group-hover:opacity-40 hover:opacity-100! hover:text-error! text-error"
                              >
                                <.icon name="hero-x-mark" class="w-3.5 h-3.5" />
                              </button>
                            </div>
                          </div>
                        </th>
                      <% end %>
                      <th class="px-2 sm:px-3 py-2 sm:py-3 text-left min-w-[48px] w-[48px] sm:min-w-[80px] sm:w-[80px]">
                        <button
                          id="add-btn"
                          phx-click="toggle-add"
                          class="btn btn-ghost btn-xs sm:btn-sm w-full flex items-center justify-center gap-0.5 text-base-content/40 hover:text-base-content/70 transition-colors"
                        >
                          <.icon name="hero-plus" class="w-4 h-4 sm:w-5 sm:h-5" />
                          <span class="text-[10px] hidden sm:inline">Add</span>
                        </button>
                      </th>
                    </tr>
                  </thead>

                  <%!-- Table Body (grouped sections) --%>
                  <tbody>
                    <%= for {group_name, specs} <- @grouped_schema do %>
                      <%!-- Section header row --%>
                      <tr class="spec-section">
                        <td
                          colspan={length(@products) + 2}
                          class="px-3 sm:px-4 py-1.5 sm:py-2 text-[10px] sm:text-xs font-bold uppercase tracking-wider spec-section-label"
                        >
                          {group_name}
                        </td>
                      </tr>

                      <%!-- Spec rows --%>
                      <%= for {spec_key, spec_meta} <- specs do %>
                        <% diffs_visible = @highlight_diffs %>
                        <% row_diffs = diffs_visible && spec_key in @diff_set %>

                        <tr class={[
                          "border-t border-base-200/80 transition-colors duration-300",
                          row_diffs && "diff-highlight"
                        ]}>
                          <td class="sticky left-0 z-10 bg-base-100 px-3 sm:px-4 py-2 sm:py-3 font-medium whitespace-nowrap text-xs sm:text-sm">
                            <div class="flex items-center gap-1.5">
                              <span>{spec_meta["label"]}</span>
                              <span :if={spec_meta["unit"]} class="text-[10px] opacity-40">
                                {spec_meta["unit"]}
                              </span>
                            </div>
                          </td>

                          <%= for product <- @products do %>
                            <% value = Map.get(product.specs, spec_key) %>
                            <% is_best =
                              is_number(value) &&
                                Comparisons.best_value(spec_key, @products, @schema_map) == value %>
                            <td class={[
                              "px-2 sm:px-3 py-2 sm:py-3 transition-colors duration-300 compare-cell",
                              row_diffs && "diff-highlight"
                            ]}>
                              <.spec_cell
                                value={value}
                                meta={spec_meta}
                                is_best={is_best}
                                products={@products}
                                spec_key={spec_key}
                                product_slug={product.slug}
                                expanded={
                                  Map.get(@expanded_benchmarks, "#{product.slug}-#{spec_key}", false)
                                }
                              />
                            </td>
                          <% end %>

                          <td class="px-2 sm:px-3 py-2 sm:py-3 text-center opacity-15">
                            <span class="text-[10px]">—</span>
                          </td>
                        </tr>
                      <% end %>
                    <% end %>
                  </tbody>
                </table>
              </div>
            </div>

            <%!-- Floating swap dropdown --%>
            <%= if @swap_slug do %>
              <div
                id="swap-dropdown"
                phx-click-away="close-swap"
                class="fixed z-50 w-56 sm:w-72 dropdown-panel"
                phx-hook=".PositionSwap"
                data-slug={@swap_slug}
              >
                <div class="bg-base-100/95 border border-base-300 rounded-xl shadow-2xl overflow-hidden">
                  <div class="p-2 border-b border-base-200">
                    <label class="input input-bordered input-xs sm:input-sm flex items-center gap-1.5">
                      <.icon
                        name="hero-magnifying-glass"
                        class="w-3 h-3 sm:w-4 sm:h-4 shrink-0 opacity-40"
                      />
                      <input
                        type="text"
                        id="swap-search-input"
                        placeholder="Search products..."
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
                        class="w-full text-left px-3 py-2.5 text-sm hover:bg-base-200 transition-colors flex items-center gap-2 border-b border-base-200/50 last:border-0"
                      >
                        <.icon name="hero-swap" class="w-4 h-4 shrink-0 opacity-40" />
                        <div class="min-w-0">
                          <div class="truncate font-medium">{candidate.name}</div>
                          <div class="text-[10px] opacity-40 truncate">{candidate.slug}</div>
                        </div>
                      </button>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>

            <%!-- Floating add dropdown --%>
            <%= if @show_add_dropdown do %>
              <div
                id="add-dropdown"
                phx-click-away="close-add"
                class="fixed z-50 w-56 sm:w-72 dropdown-panel"
                phx-hook=".PositionAdd"
              >
                <div class="bg-base-100/95 border border-base-300 rounded-xl shadow-2xl overflow-hidden">
                  <div class="p-2 border-b border-base-200">
                    <label class="input input-bordered input-sm flex items-center gap-1.5">
                      <.icon name="hero-magnifying-glass" class="w-4 h-4 shrink-0 opacity-40" />
                      <input
                        type="text"
                        id="add-search-input"
                        placeholder="Search products..."
                        class="grow outline-none bg-transparent text-sm"
                      />
                    </label>
                  </div>
                  <div class="max-h-64 overflow-y-auto" id="add-search-results">
                    <%= if @available == [] do %>
                      <div class="px-3 py-6 text-xs opacity-40 text-center">
                        All products already in comparison
                      </div>
                    <% else %>
                      <%= for avail <- @available do %>
                        <button
                          phx-click="add-product"
                          phx-value-slug={avail.slug}
                          data-name={avail.name}
                          class="w-full text-left px-3 py-2.5 text-sm hover:bg-base-200 transition-colors flex items-center gap-2 border-b border-base-200/50 last:border-0"
                        >
                          <.icon name="hero-plus-circle" class="w-4 h-4 shrink-0 opacity-40" />
                          <div class="min-w-0">
                            <div class="truncate font-medium">{avail.name}</div>
                            <div class="text-[10px] opacity-40 truncate">
                              {String.slice(avail.name, 0, 40)}
                            </div>
                          </div>
                        </button>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </Layouts.app>

    <%!-- Position swap dropdown via JS hook --%>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PositionSwap">
      export default {
        mounted() {
          this.positionDropdown()
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
        },
        updated() {
          this.positionDropdown()
        },
        positionDropdown() {
          let slug = this.el.getAttribute("data-slug")
          let btn = document.getElementById("swap-btn-" + slug)
          if (btn) {
            let rect = btn.getBoundingClientRect()
            let w = this.el.offsetWidth || 288
            this.el.style.position = "fixed"
            this.el.style.top = (rect.bottom + 4) + "px"
            this.el.style.left = Math.max(8, Math.min(rect.left, window.innerWidth - w - 8)) + "px"
            this.el.style.zIndex = "50"
          }
        }
      }
    </script>

    <%!-- Position add dropdown --%>
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PositionAdd">
      export default {
        mounted() {
          this.positionDropdown()
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
        },
        updated() {
          this.positionDropdown()
        },
        positionDropdown() {
          let btn = document.getElementById("add-btn")
          if (btn) {
            let rect = btn.getBoundingClientRect()
            let w = this.el.offsetWidth || 288
            this.el.style.position = "fixed"
            this.el.style.top = (rect.bottom + 4) + "px"
            this.el.style.left = Math.max(8, rect.right - w) + "px"
            this.el.style.zIndex = "50"
          }
        }
      }
    </script>
    """
  end

  attr :value, :any
  attr :meta, :map, default: %{}
  attr :is_best, :boolean, default: false
  attr :products, :list, default: []
  attr :spec_key, :string, default: ""
  attr :product_slug, :string, default: ""
  attr :expanded, :boolean, default: false

  def spec_cell(assigns) do
    ~H"""
    <div class="flex flex-col gap-1">
      <%= cond do %>
        <% is_nil(@value) or @value == "" -> %>
          <span class="opacity-30 text-xs">—</span>
        <% is_list(@value) -> %>
          <%!-- Subjective multi-source — collapsed by default, click to expand --%>
          <% numeric_vals = Enum.map(@value, & &1["numeric_value"]) |> Enum.reject(&is_nil/1) %>
          <% avg = if numeric_vals != [], do: round(Enum.sum(numeric_vals) / length(numeric_vals)) %>
          <% expanded_key = "#{@product_slug}-#{@spec_key}" %>

          <div class="flex items-center gap-1">
            <span class="font-semibold text-sm tabular-nums">
              {if avg, do: "#{avg}%", else: "—"}
            </span>
            <span class="text-[10px] opacity-40">
              ({length(@value)} sources)
            </span>
            <button
              phx-click="toggle-benchmark"
              phx-value-key={expanded_key}
              class="ml-auto btn btn-ghost btn-xs p-0.5 min-h-0 h-5 w-5 opacity-40 hover:opacity-100 transition-opacity"
              title="Show sources"
            >
              <.icon
                name={if @expanded, do: "hero-chevron-up", else: "hero-chevron-down"}
                class="w-3 h-3"
              />
            </button>
          </div>

          <%= if @expanded do %>
            <div class="space-y-0.5 mt-1 pt-1 border-t border-base-300/50">
              <%= for entry <- @value do %>
                <div class="flex items-center justify-between gap-1">
                  <span class="text-[10px] opacity-50 truncate">{entry["source"]}</span>
                  <span class="font-semibold text-xs tabular-nums">{entry["value"]}</span>
                </div>
              <% end %>
              <%= if numeric_vals != [] do %>
                <div class="mt-1 h-1.5 rounded-full bg-base-300 overflow-hidden">
                  <div
                    class="h-full rounded-full bg-primary/60 spec-bar"
                    style={"width: #{avg}%"}
                  />
                </div>
              <% end %>
            </div>
          <% end %>
        <% is_number(@value) -> %>
          <% show_bar = @meta["visual"] == "bar" %>
          <% bar_w = if show_bar, do: Comparisons.bar_width(@value, @spec_key, @products) %>
          <div class="flex items-center gap-2">
            <span class={[
              "font-semibold tabular-nums text-sm",
              @is_best && "text-success"
            ]}>
              {@value}{@meta["unit"]}
            </span>
            <%= if @is_best do %>
              <.icon name="hero-check-circle" class="w-3.5 h-3.5 text-success shrink-0" />
            <% end %>
          </div>
          <%= if show_bar do %>
            <div class="h-1.5 rounded-full bg-base-300 overflow-hidden">
              <div
                class={[
                  "h-full rounded-full spec-bar",
                  @is_best && "bg-success",
                  !@is_best && "bg-primary/50"
                ]}
                style={"width: #{bar_w}%"}
              />
            </div>
          <% end %>
        <% true -> %>
          <span class="font-medium text-sm">{@value}</span>
      <% end %>
    </div>
    """
  end
end
