# anything.compare

**Zero-admin, infinitely scalable comparison engine.**
Data is crowdsourced via GitHub PRs. Pages load in <1ms. New categories require zero code.

```
phone.anything.compare  →  phones side-by-side
laptop.anything.compare →  laptops side-by-side
pizza.anything.compare  →  ...you get the idea
```

## How it works

1. **Data lives in a public GitHub repo** — plain CSV + `schema.json` per category
2. **Community edits via PRs** — GitHub Actions validates format, no dupes, required fields
3. **PR merge triggers a webhook** → Oban worker ingests into PostgreSQL
4. **ETS memory cache** — sub-millisecond reads, automatically reloaded
5. **LiveView pushes updates** — zero-refresh UI for every connected visitor

No admin panel. No schema migrations. No deploy for new categories.

## Stack

| Layer | Technology |
|-------|-----------|
| Language | Elixir (BEAM) |
| Web | Phoenix LiveView + HEEx |
| Database | PostgreSQL (JSONB + GIN indexes) |
| Cache | ETS (in-memory, sub-ms reads) |
| Background jobs | Oban |
| Styling | Tailwind CSS |

## Quickstart

```bash
mix setup
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000).

## Data format

Each category is a folder in the dataset repo with two files:

**`schema.json`** — field definitions:

```json
{
  "brand":       { "type": "string",  "label": "Brand",            "filterable": true },
  "battery_mah": { "type": "number",  "label": "Battery Capacity", "unit": "mAh" },
  "stability":   { "type": "subjective", "label": "Stress Stability" }
}
```

**`data.csv`** — product rows:

```csv
brand,model,battery_mah,stability
Samsung,Galaxy S24,4000,74%@GSM Arena | 68%@AnandTech
```

Subjective fields aggregate multiple review sources in one cell using `value@source | value@source` syntax.

## Routes

| URL | Page |
|-----|------|
| `anything.compare` | Category explorer |
| `{cat}.anything.compare` | Category catalog |
| `/compare/:slugs` | Side-by-side matrix |
| `/product/:slug` | Product detail |

## Deployment

See [`plans/DEPLOYMENT.md`](plans/DEPLOYMENT.md).

## License

MIT
