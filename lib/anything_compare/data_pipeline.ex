defmodule AnythingCompare.DataPipeline do
  alias AnythingCompare.Repo
  alias AnythingCompare.Products.Product
  alias AnythingCompare.DataPipeline.Parser

  def process_ingestion(category, schema_data, csv_rows) do
    products = Parser.parse_csv_rows(csv_rows, schema_data)

    Repo.transaction(fn ->
      Enum.each(products, fn product_attrs ->
        %Product{}
        |> Product.changeset(%{
          id: Ecto.UUID.generate(),
          name: product_attrs["name"],
          slug: product_attrs["slug"],
          category: category,
          specs: product_attrs["specs"]
        })
        |> Repo.insert(
          on_conflict: {:replace_all_except, [:id, :inserted_at]},
          conflict_target: [:category, :slug]
        )
      end)
    end)

    AnythingCompare.Cache.Storage.reload_category(category, schema_data)

    {:ok, length(products)}
  end
end
