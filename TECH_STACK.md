# anything.compare — Technology Stack

## Core

| Technology | Purpose |
|-----------|---------|
| **Elixir** | Functional, fault-tolerant runtime (BEAM) |
| **Phoenix LiveView** | Real-time, zero-refresh UI — rich interactive matrices without JS frameworks |
| **PostgreSQL** | Primary persistence, JSONB for flexible schemas, GIN indexing |
| **ETS (Erlang Term Storage)** | In-memory cache layer — sub-millisecond reads, GenServer-managed |

## Ingestion & Processing

| Technology | Purpose |
|-----------|---------|
| **Oban** | Background job orchestration — async ingestion pipeline, retries, fault tolerance |
| **NimbleCSV** | RFC 4180 CSV parsing — lightweight, no dependencies |
| **Req** | HTTP client — fetch raw CSV/schema from GitHub |
| **Jasny** | JSON schema parsing |

## Web Layer

| Technology | Purpose |
|-----------|---------|
| **Phoenix Router** | Subdomain-based routing via custom Plug |
| **LiveView (HEEx)** | Dynamic schema-driven matrix rendering |
| **Tailwind CSS** | Utility-first styling — mobile swipe, sticky headers, diff highlights |

## DevOps & CI/CD

| Technology | Purpose |
|-----------|---------|
| **GitHub Actions** | Pre-merge validation (schema compliance, dedup, required fields) |
| **GitHub Webhooks** | Trigger ingestion pipeline on merge to production branch |
| **Docker / Fly.io or Gigalixir** | Deployment targets (BEAM-native hosting) |

## Library Versions (planned)

- Elixir ~> 1.17
- Phoenix ~> 1.7
- Oban ~> 2.18
- NimbleCSV ~> 1.5
- Req ~> 0.5
- Jasny ~> 2.0
- Ecto ~> 3.12
- Postgrex ~> 0.19
