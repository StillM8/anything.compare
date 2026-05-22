# anything.compare — Deployment & Operations

## CI/CD Pipeline

### GitHub Actions (Dataset Validation)
File: `.github/workflows/validate-data.yml`

Triggers on PRs touching `/data/**`.
Checks:
1. `schema.json` validity + required keys
2. `data.csv` column ↔ schema alignment
3. Required field completeness
4. Subjective format regex (`\d+%@\S+`)
5. Duplicate `brand+model` detection
6. Numeric type coercion test

### Fly.io / Docker Deploy
- `Dockerfile` with Elixir release
- `fly.toml` configuring:
  - PostgreSQL cluster (with pgvector optional)
  - VM size scaling
  - Autostart/restart

## Webhook Security

| Header | Purpose |
|--------|---------|
| `X-Hub-Signature-256` | HMAC-SHA256 of raw payload using shared secret |
| `X-GitHub-Event` | Event type filter (only `push` processed) |

Endpoint: `POST /webhooks/github`
- Read raw body
- Compute HMAC, constant-time compare
- Reject on mismatch
- Enqueue Oban job with category + file URLs

## Production Checklist

- [ ] Phoenix secret key base
- [ ] GitHub webhook secret in runtime env
- [ ] PostgreSQL SSL enforced
- [ ] ETS warm-up on deploy (no cold-start gaps)
- [ ] Rate limiting on webhook endpoint (Oban max attempts: 3)
- [ ] CDN (Cloudflare / Fly Anycast) for static assets
- [ ] Uptime monitoring (health check: `GET /health`)
- [ ] Database connection pooling (Repo pool size tuned to CPU count)
- [ ] Oban queues: `ingestion` (max_concurrency: 1 to avoid race conditions)
- [ ] Log level: `:info` in prod, structured JSON logging

## Monitoring

- LiveDashboard (`/dev/dashboard`) — restricted to admin IP
- Telemetry + Phoenix Logger for ingestion errors
- Oban Web UI for job retries/failures
- ETS cache hit ratio tracked via Telemetry event

## Scaling

| Bottleneck | Solution |
|------------|----------|
| High read traffic | ETS absorbs reads, PostgreSQL spared |
| Large CSV files | Oban processes out-of-band, connection pool |
| Many categories | Subdomain routing is O(1), no route table bloat |
| Concurrent editors | Git handles merge conflicts naturally at line level |
