# anything.compare — Data Strategy

## Why CSV (Not XLSX, Not JSON)

| Format | Git Diff | Merge | Verdict |
|--------|----------|-------|---------|
| XLSX | Binary blob (full rewrite) | Impossible | Rejected |
| JSON | Line-level, but verbose | Manual conflicts common | Verbose for large datasets |
| **CSV** | **True line-level diffs** | **Atomic auto-merge** | **Chosen** |

CSV is the only format where 100 concurrent edits on different rows merge cleanly via standard Git.

## Repository Structure

```
/data
├── /phone
│   ├── schema.json
│   └── data.csv
├── /laptop
│   ├── schema.json
│   └── data.csv
└── /pizza
    ├── schema.json
    └── data.csv
```

Every category is self-describing. Adding "camera" = creating `data/camera/schema.json` + `data/camera/data.csv`.

## Schema Definitions (`schema.json`)

Each field type controls rendering + filtering + sorting:

```json
{
  "brand":       { "type": "string",    "label": "Brand",            "filterable": true  },
  "model":       { "type": "string",    "label": "Model",            "filterable": false },
  "battery_mah": { "type": "number",    "label": "Battery Capacity", "unit": "mAh",      "visual": "bar" },
  "price_usd":   { "type": "number",    "label": "Launch Price",     "unit": "$",        "visual": "bar" },
  "os":          { "type": "string",    "label": "OS",               "filterable": true  },
  "stability":   { "type": "subjective","label": "Stress Stability", "unit": "%",        "visual": "bar" }
}
```

**Types:**
- `string` — text label, optionally filterable
- `number` — numeric with optional unit, renders as progress bar
- `subjective` — multi-source pipe-@ delimited values (see below)

## Subjective Data Engine

Captures review-aggregator variation in a single CSV cell:

```
74%@GSM Arena | 68%@AnandTech | 71%@Tom's Guide
```

Parsed by the ingestion pipeline into:

```elixir
[
  %{"value" => "74%", "source" => "GSM Arena",  "numeric_value" => 74.0},
  %{"value" => "68%", "source" => "AnandTech",  "numeric_value" => 68.0},
  %{"value" => "71%", "source" => "Tom's Guide", "numeric_value" => 71.0}
]
```

Stored in JSONB under `specs["stability"]` as an array.

## PostgreSQL Schema

```sql
CREATE TABLE products (
  id         UUID PRIMARY KEY,
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL,
  category   TEXT NOT NULL,
  specs      JSONB NOT NULL DEFAULT '{}',
  inserted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_products_category_slug ON products (category, slug);
CREATE INDEX idx_products_category        ON products (category);
CREATE INDEX idx_products_specs_gin       ON products USING GIN (specs);
```

No migrations needed for new categories — `specs` is a flexible JSONB document.

## PR Validation (GitHub Actions)

Every PR targeting `main` must pass:
1. `schema.json` exists and is valid JSON
2. `data.csv` column headers match `schema.json` keys
3. No blank required fields
4. Subjective cells match `Value@Source` format
5. No duplicate `brand+model` rows
6. Data types match schema (numeric cells parse as numbers)
