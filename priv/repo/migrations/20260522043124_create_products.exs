defmodule AnythingCompare.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :slug, :string, null: false
      add :category, :string, null: false
      add :specs, :map, null: false, default: "{}"

      timestamps()
    end

    create unique_index(:products, [:category, :slug])
    create index(:products, [:category])
    execute "CREATE INDEX idx_products_specs_gin ON products USING GIN (specs);"
  end
end
