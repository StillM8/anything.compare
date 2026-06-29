defmodule AnythingCompare.DataPipeline do
  alias AnythingCompare.Repo
  alias AnythingCompare.Products.Product
  alias AnythingCompare.DataPipeline.Parser

  def process_ingestion(category, schema_data, csv_rows) do
    products = Parser.parse_csv_rows(csv_rows, schema_data)

    {inserted, errors} =
      Enum.reduce(products, {0, []}, fn product_attrs, {count, errs} ->
        result =
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

        case result do
          {:ok, _} ->
            {count + 1, errs}

          {:error, changeset} ->
            slug = product_attrs["slug"]

            IO.warn(
              "[DataPipeline] insert failed: slug=#{inspect(slug)} errors=#{inspect(changeset.errors)}"
            )

            {count, [changeset | errs]}
        end
      end)

    if errors != [] do
      IO.warn(
        "[DataPipeline] #{inserted} inserted, #{length(errors)} failed for category=#{category}"
      )
    end

    AnythingCompare.Cache.Storage.reload_category(category, schema_data)

    {:ok, inserted}
  end
end
