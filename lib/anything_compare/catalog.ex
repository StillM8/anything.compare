defmodule AnythingCompare.Catalog do
  import Ecto.Query, warn: false
  alias AnythingCompare.Repo
  alias AnythingCompare.Products.Product

  def list_products(category) do
    Repo.all(from p in Product, where: p.category == ^category, order_by: p.name)
  end

  def get_product!(category, slug) do
    Repo.get_by!(Product, category: category, slug: slug)
  end

  def get_products_for_comparison(category, slugs) do
    Repo.all(from p in Product, where: p.category == ^category and p.slug in ^slugs)
  end

  def upsert_product(category, attrs) do
    slug = attrs["slug"]

    %Product{}
    |> Product.changeset(%{
      id: attrs["id"] || Ecto.UUID.generate(),
      name: attrs["name"] || slug,
      slug: slug,
      category: category,
      specs: attrs["specs"] || %{}
    })
    |> Repo.insert(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:category, :slug]
    )
  end

  def list_categories do
    Repo.all(from p in Product, select: p.category, distinct: true, order_by: p.category)
  end

  def count_products(category) do
    Repo.one(from p in Product, where: p.category == ^category, select: count(p.id))
  end

  def search_products(category, query) do
    like = "%#{query}%"

    Repo.all(
      from p in Product,
        where: p.category == ^category and (ilike(p.name, ^like) or ilike(p.slug, ^like)),
        order_by: p.name
    )
  end
end
