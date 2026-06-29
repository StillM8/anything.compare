defmodule AnythingCompare.Cache.Storage do
  use GenServer

  @table_name :products_cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}, {:continue, :warm_cache}}
  end

  def handle_continue(:warm_cache, state) do
    reload_all_categories()
    warm_schema_from_disk()
    {:noreply, state}
  end

  def get_products(category) do
    case :ets.lookup(@table_name, category) do
      [{^category, products}] ->
        products

      [] ->
        # Fallback: query PostgreSQL directly if cache not warmed yet
        products = AnythingCompare.Catalog.list_products(category)

        if products != [] do
          update_category(category, products)
          products
        else
          []
        end
    end
  end

  def get_products_for_comparison(category, slugs) do
    products = get_products(category)
    Enum.filter(products, &(Map.get(&1, :slug) in slugs))
  end

  def get_schema(category) do
    case :ets.lookup(@table_name, {:schema, category}) do
      [{_, schema}] -> schema
      [] -> %{}
    end
  end

  def update_category(category, products) do
    :ets.insert(@table_name, {category, products})
  end

  def update_category_schema(category, schema) do
    :ets.insert(@table_name, {{:schema, category}, schema})
  end

  def reload_category(category, schema \\ nil) do
    products = AnythingCompare.Catalog.list_products(category)
    update_category(category, products)
    if schema, do: update_category_schema(category, schema)
  end

  def reload_all_categories do
    categories = AnythingCompare.Catalog.list_categories()
    Enum.each(categories, &reload_category(&1))
  end

  # On startup, scan /data/{category}/schema.json files and load them into ETS.
  # This way compare-view labels/units work without depending on webhook flow.
  def warm_schema_from_disk do
    data_root = Path.join([File.cwd!(), "data"])

    if File.exists?(data_root) do
      data_root
      |> File.ls!()
      |> Enum.each(fn category ->
        schema_path = Path.join([data_root, category, "schema.json"])

        if File.exists?(schema_path) do
          schema = schema_path |> File.read!() |> Jason.decode!()
          update_category_schema(category, schema)
        end
      end)
    end
  end
end
