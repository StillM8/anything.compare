# anything.compare — Data Model

## Category Schema Definition (`schema.json`)

Each category has a `schema.json` that governs storage profiles and frontend rendering:

```json
{
  "brand": {
    "type": "string",
    "label": "Brand",
    "filterable": true
  },
  "model": {
    "type": "string",
    "label": "Model",
    "filterable": false
  },
  "battery_mah": {
    "type": "number",
    "label": "Battery Capacity",
    "unit": "mAh",
    "visual": "bar"
  },
  "price_usd": {
    "type": "number",
    "label": "Launch Price",
    "unit": "$",
    "visual": "bar"
  },
  "os": {
    "type": "string",
    "label": "Operating System",
    "filterable": true
  },
  "stress_test_stability": {
    "type": "subjective",
    "label": "Stress Test Stability",
    "unit": "%",
    "visual": "range"
  }
}
```

### Supported Types

| Type | Description |
|------|-------------|
| `string` | Plain text, optionally filterable |
| `number` | Numeric value with optional unit, renders as bar |
| `subjective` | Multiple-source values (see delimiter format) |

## Multi-Source Subjective Data Engine

Hard parameters (e.g., 8GB RAM) are explicit. Subjective parameters (battery runtimes, stability ratings) vary by reviewer. The **Pipe-At Delimiter Trick** serializes multiple assessments in a single cell:

```
74%@GSM Arena | 68%@AnandTech | 71%@Tom's Guide
```

**Parsing logic:**
1. Split by `|` → row instances
2. Split each instance by `@` → [value, source]
3. Extract numeric prefix from value

## PostgreSQL Schema (JSONB)

```sql
CREATE TABLE products (
  id          UUID PRIMARY KEY,
  name        TEXT NOT NULL,
  slug        TEXT NOT NULL,
  category    TEXT NOT NULL,
  specs       JSONB NOT NULL DEFAULT '{}',
  inserted_at TIMESTAMPTZ NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX idx_products_category_slug ON products (category, slug);
CREATE INDEX idx_products_category ON products (category);
CREATE INDEX idx_products_specs_gin ON products USING GIN (specs);
```

## ETS Cache Layer

- Named table `:products_cache`
- Key: `{:category, "phone"}` → value: list of products
- Warmed on boot via `c: :warm_cache`
- Invalidated & reloaded after each Oban ingestion cycle
- Read concurrency enabled
