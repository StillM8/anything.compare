# anything.compare — Project Plan

## Vision
A high-performance, horizontally scaling comparison platform where any category (phones, laptops, pizzas, etc.) can be added without code changes or database migrations. Content is crowdsourced via GitHub PRs — no admin panel needed.

## Principle
**Git-as-a-Database.** All source data lives in a public GitHub repo as plain-text CSV files with companion `schema.json` metadata. Merged PRs trigger webhooks → automated ingestion into PostgreSQL + ETS memory cache.

## Milestones

| Phase | What | Deliverable |
|-------|------|-------------|
| **P0** | Foundation | Elixir/Phoenix project scaffolded, PostgreSQL + ETS setup, subdomain plug, basic LiveView shell |
| **P1** | Data Pipeline | GitHub webhook ingestion, Oban workers, CSV→JSONB parsing, subjective delimiter engine, data normalization |
| **P2** | Comparison UI | Dynamic spec matrix, highlight-differences toggle, mobile swipe, missing-value prompts, product detail pages |
| **P3** | Crowd Layer | Public GitHub dataset repo, schema validators, PR template, GitHub Actions CI for structural checks |
| **P4** | SEO & Scale | Pre-rendered product/compare routes, GIN index tuning, ETS warming, CDN, rate limiting |

## Naming Convention
- **Repository:** `anything.compare`
- **Domain:** `anything.compare` (apex)
- **Subdomains:** `{category}.anything.compare` (e.g., `phone.anything.compare`)
- **App module:** `AnythingCompare`

## Tech Stack
- **Language/Framework:** Elixir, Phoenix LiveView
- **Database:** PostgreSQL 16+ (JSONB columns)
- **Cache:** Erlang Term Storage (ETS)
- **Queue:** Oban
- **Data storage:** Public GitHub repo (CSV + schema.json)
- **HTTP client:** Req (for fetching raw data from GitHub)
- **CSV parsing:** NimbleCSV
