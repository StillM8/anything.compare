defmodule AnythingCompare.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field :name, :string
    field :slug, :string
    field :category, :string
    field :specs, :map, default: %{}

    timestamps()
  end

  def changeset(product, attrs) do
    product
    |> cast(attrs, [:id, :name, :slug, :category, :specs])
    |> validate_required([:name, :slug, :category])
    |> unique_constraint([:category, :slug])
  end
end
