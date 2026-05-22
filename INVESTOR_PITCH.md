# anything.compare — Investor Pitch

> **A zero-admin, horizontally scaling comparison engine for every category on Earth.**
> Data is crowdsourced via GitHub PRs. Pages load in <1ms. New categories require zero code.

---

## The Problem

Comparison shopping is broken in two ways:

**For users:** Existing comparison sites (CNET, TechRadar, Wirecutter) are curated by small editorial teams. They cover maybe 200 products across 5 categories. If you want to compare a Xiaomi phone sold only in Asia against an iPhone, or compare GPU rendering benchmarks across 40 GPUs, or compare vegan protein powders by amino acid profile — you're out of luck. The long tail of comparison queries is entirely unserved.

**For operators:** Building a comparison site today means:
- Designing a database schema per category
- Building an admin panel with user roles and permissions
- Writing import scripts for every data source
- Constant schema migrations as new specs emerge
- Hiring moderators to validate submissions

This takes 6–18 months and a team of 5+ engineers per category. It doesn't scale.

---

## The Solution

**anything.compare** inverts the model.

### Git-as-a-Database
All product data lives in a **public GitHub repository** as plain-text CSV files with companion `schema.json` metadata files. Contributors submit changes via Pull Requests.

```
/data/phone/schema.json   ← column definitions (type, label, unit, visual)
/data/phone/data.csv       ← the actual product rows
```

### Fully Automated Loop

1. User edits `data.csv` on GitHub → opens a PR
2. **GitHub Actions** validates schema conformance, required fields, no duplicates
3. PR merges → **webhook** fires to our Elixir server
4. **Oban worker** fetches files, parses CSV, normalizes data
5. **PostgreSQL** bulk upsert into JSONB columns (no migrations ever)
6. **ETS memory cache** flushed and reloaded — sub-millisecond reads
7. **Phoenix LiveView** pushes the update to every connected user without a page refresh

**Result:** Zero manual intervention. Zero schema migrations. Zero admin panel.

### Subjective Data Engine
Hard specs (e.g., "8GB RAM") are easy. Subjective specs (e.g., "battery life") vary by reviewer. Our pipe-`@` delimiter convention captures multi-source data in a single CSV cell:

```
74%@GSM Arena | 68%@AnandTech | 71%@Tom's Guide
```

Parsed into structured JSONB arrays — users see both the aggregate and the source breakdown.

### Infinite Categories
New category = new folder in the GitHub repo. No code change. No deploy. No migration.

```
/data/phone/     ← live at phone.anything.compare
/data/laptop/    ← live at laptop.anything.compare
/data/pizza/     ← live at pizza.anything.compare
/data/gpu/       ← you get the idea
```

---

## Market Opportunity

| Metric | Value |
|--------|-------|
| Global e-commerce market | $6.3T (2024) |
| Shoppers who compare before buying | 82% |
| Product comparison searches per month | ~1.2B (Google) |
| Average time-to-purchase with comparison | 2.3× faster |
| Existing comparison site TAM | $4.8B (ad revenue + affiliate) |

**Key insight:** The top 10 comparison sites cover ~50 categories. Our architecture enables **thousands**. Each new category is a new SEO vector, a new affiliate revenue stream, and a new reason for users to visit.

---

## Business Model

### Phase 1 — Affiliate Revenue
Every product page and comparison matrix links to purchase options via affiliate networks (Amazon Associates, eBay Partner Network, etc.). Commission rates: 2–10%.

**Projected RPM** (Revenue Per Mille visitors): $12–18 (industry avg for comparison sites is $8–14; our longer-tail categories command higher rates).

### Phase 2 — Sponsored Categories
Brands pay $5k–$20k/mo to be the "official" category sponsor (e.g., "GPU benchmarks powered by NVIDIA").

### Phase 3 — Data API
Programmatic access to the spec database for retailers, researchers, and AI training. Tiered pricing:
- Community: free (100 req/day)
- Developer: $49/mo (10k req/day)
- Enterprise: custom

---

## Competitive Moat

| Competitor | Categories | Data Freshness | Crowdsourced | Speed |
|------------|-----------|----------------|--------------|-------|
| CNET | ~8 | Editorial cycle (days) | No | ~2s |
| GSMArena | ~1 (phones) | Editorial | No | ~1.5s |
| Wirecutter | ~15 | Paid staff | No | ~3s |
| RTINGS.com | ~6 | Paid testers | No | ~1s |
| **anything.compare** | **∞** | **Real-time (PR merge → live in seconds)** | **Yes — global crowd** | **<1ms** |

**Defensibility:**
1. **Data network effect** — the more categories we have, the more contributors we attract, the more data we have, the more visitors come. Classic flywheel.
2. **Git-based contribution** is a moat because we don't need to build/maintain a write API, admin panel, or permission system. Nobody else has the talent to operate this model.
3. **Unlimited categories** means unlimited SEO surface area. Every new category is a new indexable content tree.
4. **Sub-1ms page loads** (ETS) means best-in-class Core Web Vitals, which means Google ranking preference.

---

## Traction Roadmap

| Quarter | Milestone |
|---------|-----------|
| Q1 2026 | Elixir/Phoenix scaffold, subdomain plug, ETS cache, basic matrix LiveView |
| Q2 2026 | Oban ingestion pipeline, GitHub webhook integration, PR validator CI |
| Q3 2026 | Launch with 1 anchor category (phones). Public GitHub dataset repo. |
| Q4 2026 | 3 categories, highlight-differences UI, mobile swipe, SEO pre-rendering |
| Q1 2027 | 10 categories, affiliate integration, sponsored category pilot |
| Q2 2027 | 50+ categories, contributor badges gamification, data API v1 |
| Q3 2027 | 200+ categories — full community flywheel engaged |

---

## Why Elixir/Phoenix?

| Requirement | How Elixir delivers |
|-------------|-------------------|
| Sub-millisecond reads | ETS (in-memory, lock-free, runs inside BEAM) |
| Real-time UI updates | LiveView (WebSocket push, no React/Vue SPA needed) |
| Reliable background jobs | Oban (PostgreSQL-backed, retries, CRON scheduling) |
| Horizontal scaling | BEAM actor model — add nodes, no re-architect |
| Fault tolerance | Supervisor trees — "let it crash" philosophy |
| JSONB handling | Ecto + PostgreSQL GIN index support out of box |
| CSV parsing | NimbleCSV (fastest Elixir CSV parser) |



## Summary

**anything.compare** is a technical moat play in a $4.8B market.

- Zero-admin, infinite-category comparison engine
- Git-as-a-Database with CSV → LiveView pipeline
- Sub-millisecond page loads via ETS
- Community-sourced data with automatic validation
- Revenue: affiliate → sponsorships → API

> **One repo. One deploy. Infinite comparisons.**
