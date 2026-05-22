defmodule AnythingCompareWeb.CatalogLive.Detail do
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
    {:ok, assign(socket, :current_category, current_category)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    category = resolve_category(socket.assigns, params)
    slug = params["slug"] || ""

    product = AnythingCompare.Catalog.get_product!(category, slug)
    schema = AnythingCompare.Cache.Storage.get_schema(category)
    effective_schema = if schema == %{}, do: @sample_schema, else: schema

    {:noreply,
     assign(socket,
       category: category,
       product: product,
       schema: effective_schema,
       page_title: "#{product.name} | anything.compare"
     )}
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
        <div class="max-w-4xl mx-auto px-4 py-8">
          <.link
            navigate={~p"/#{@category}"}
            class="text-sm opacity-60 hover:opacity-100 transition-opacity inline-flex items-center gap-1 mb-6"
          >
            ← Back to {@category}
          </.link>

          <div class="flex items-start justify-between mb-8">
            <div>
              <h1 class="text-3xl font-bold">{@product.name}</h1>
              <p class="text-sm opacity-50 mt-1 capitalize">{@category}</p>
            </div>
            <.link
              navigate={~p"/#{@category}/compare/#{@product.slug}"}
              class="btn btn-primary btn-sm"
            >
              <.icon name="hero-arrows-right-left" class="w-4 h-4" />
              Compare
            </.link>
          </div>

          <div class="rounded-xl border border-base-300 bg-base-100 overflow-hidden">
            <table class="w-full text-sm">
              <tbody>
                <%= for {spec_key, spec_meta} <- @schema do %>
                  <tr class="border-t border-base-300 even:bg-base-200/50">
                    <td class="px-5 py-3 font-medium whitespace-nowrap w-1/3">
                      <div class="flex items-center gap-2">
                        <span>{spec_meta["label"]}</span>
                        <span class="text-xs opacity-40">{spec_meta["unit"]}</span>
                      </div>
                    </td>
                    <td class="px-5 py-3">
                      <.detail_spec_cell value={@product.specs[spec_key]} meta={spec_meta} />
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  def detail_spec_cell(assigns) do
    value = assigns.value
    meta = assigns.meta

    assigns =
      cond do
        is_nil(value) or value == "" ->
          assign(assigns, :cell, "—")

        is_list(value) ->
          assign(assigns, :subjective_entries, value)

        is_number(value) ->
          unit = Map.get(meta, "unit", "")
          assign(assigns, :cell, "#{value}#{unit}")

        true ->
          assign(assigns, :cell, "#{value}")
      end

    ~H"""
    <%= if assigns[:subjective_entries] do %>
      <div class="space-y-1.5">
        <%= for entry <- @subjective_entries do %>
          <div class="flex items-center justify-between text-sm">
            <span class="opacity-70">{entry["source"]}</span>
            <span class="font-medium">{entry["value"]}</span>
          </div>
        <% end %>
      </div>
    <% else %>
      {@cell}
    <% end %>
    """
  end
end
