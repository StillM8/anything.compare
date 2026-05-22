# anything.compare — Infrastructure & Deployment

## Domain Architecture

```
anything.compare             → Root landing / category browser
{category}.anything.compare  → Category-specific matrix (e.g., phone.anything.compare)
api.anything.compare         → JSON API for external consumers
```

## GitHub Webhook Integration

### Endpoint Security

- Phoenix endpoint validates `X-Hub-Signature-256` using HMAC-SHA256 with an encrypted env secret
- Rejects unauthenticated payloads before any processing

### Trigger Condition

- Webhook fires on `push` events to the `production` branch of the dataset repository
- Payload includes category path, CSV URL, and schema URL

## Pre-Merge Validation (GitHub Actions)

Every PR must pass automated checks before merging into `production`:

1. **Schema compliance** — `data.csv` column headers must match `schema.json` keys exactly
2. **Required fields** — No blank required fields
3. **Delimiter validation** — Subjective cells must follow `Value@Source` convention
4. **No duplicates** — No duplicate rows sharing identical brand+model values

## Deployment Target Options

| Platform | Pros |
|----------|------|
| **Fly.io** | Global regions, BEAM-native, Postgres as a service, ETS works across VMs |
| **Gigalixir** | Purpose-built for Phoenix, free tier, simple deploys |
| **Hetzner + Docker** | Cheaper at scale, full control |

## Proposed CI/CD Pipeline

```
PR opened → GitHub Actions: validate CSV + schema
PR merged → Webhook → Phoenix /webhook endpoint
         → Oban.CategorySyncWorker enqueued
           → Fetch tarball from GitHub raw
             → Parse & normalize
               → Upsert PostgreSQL
                 → Reload ETS cache
```

## Monitoring & Observability

- Phoenix LiveDashboard for BEAM introspection
- Oban UI for job queue monitoring
- Elixir Logger + structured logging
- Sentry (or AppSignal) for error tracking
