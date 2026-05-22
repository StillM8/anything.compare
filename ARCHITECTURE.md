# anything.compare — Architecture

## System Flow

```
┌──────────────────────────────────────────────────────────┐
│  Public GitHub Repo (Source of Truth)                    │
│  /data/{category}/schema.json + data.csv                 │
└──────────┬───────────────────────────────────────────────┘
           │ PR merged → webhook fires
           ▼
┌──────────────────────┐      ┌──────────────────────────┐
│  Phoenix Endpoint     │─────▶│  Oban Worker             │
│  (signature-verify)   │      │  fetch & parse CSV+JSON  │
└──────────────────────┘      │  normalize & upsert       │
                              │  flush ETS cache          │
                              └──────────┬────────────────┘
                                         ▼
                              ┌──────────────────────────┐
                              │  PostgreSQL (JSONB)       │
                              │  products table           │
                              │  GIN-indexed specs        │
                              └──────────┬────────────────┘
                                         ▼
                              ┌──────────────────────────┐
                              │  ETS (read-optimized)     │
                              │  GenServer warm on boot   │
                              │  sub-ms lookups           │
                              └──────────┬────────────────┘
                                         ▼
                              ┌──────────────────────────┐
                              │  LiveView (no refresh)    │
                              │  matrix, detail, compare  │
                              └──────────────────────────┘
```

## Core Components

### 1. Subdomain Routing Plug
Extracts category from host header (`phone.anything.compare` → `phone`). Falls back to `root` for the apex domain.

### 2. Data Ingestion Pipeline
- Webhook received → signature validated (X-Hub-Signature-256)
- Oban `CategorySyncWorker` enqueued
- Worker fetches `schema.json` + `data.csv` from GitHub raw URLs
- `DataPipeline` parses CSV rows, applies schema types, normalizes subjective fields (`Value@Source` delimiters)
- Bulk upsert to `products` table
- ETS cache flushed and reloaded

### 3. In-Memory Cache (ETS)
- `:products_cache` named table, `:set` type, `read_concurrency: true`
- Key: `{:category, "phone"}`, Value: list of parsed product maps
- Warmed on app boot from PostgreSQL
- Invalidated after every ingestion run

### 4. LiveView Interfaces
- `CatalogLive.Index` — category landing, filter/sort controls
- `CatalogLive.Compare` — side-by-side matrix for selected products
- `CatalogLive.Detail` — single product deep-dive

## Operational Loop (End-to-End)

1. Contributor edits `data.csv` via GitHub UI or local clone
2. Opens PR → GitHub Actions runs validation (schema conformance, required fields, duplicate check)
3. PR merges to `main`
4. GitHub webhook POSTs to `/webhook/github` on `anything.compare`
5. Phoenix verifies HMAC signature
6. Oban enqueues sync job
7. Worker fetches updated files, parses, normalizes
8. PostgreSQL bulk upsert
9. ETS cache reloaded
10. LiveView pushes zero-refresh UI update to all active visitors
