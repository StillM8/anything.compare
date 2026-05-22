# anything.compare — Routes & UI

## Domain Routing

| Pattern | Behaviour |
|---------|-----------|
| `anything.compare` | Root landing (category explorer) |
| `{cat}.anything.compare` | Extracts `cat` as `@current_category`, renders category catalog |
| `www.anything.compare` | Redirects to apex |
| `api.anything.compare` | (Future) JSON API |

## URL Structure

```
GET  /                              → CatalogLive.Index (root — show all categories)
GET  /compare/:slugs                → CatalogLive.Compare (multi-product matrix)
GET  /product/:slug                 → CatalogLive.Detail (single product)
```

Under subdomain `phone.anything.compare`:
```
GET  /                              → filtered to phone category
GET  /compare/iphone-15-pro-vs-galaxy-s24  → matrix
GET  /product/iphone-15-pro         → detail
```

## LiveView Components

### CatalogLive.Index
- Category landing page
- Filter pills (brand, os, etc. — driven by `schema.json` "filterable" fields)
- Sort controls (by any numeric field)
- Product cards with key specs
- Search bar for name/specs

### CatalogLive.Compare
- Side-by-side spec matrix
- Leftmost column = spec labels (sticky)
- Columns = selected products
- "Highlight Differences" toggle — diverging rows get `.bg-warning-tint`
- Missing values show `—` linking to GitHub edit URL
- `@category_schema` drives dynamic row rendering (no hardcoded views)

### CatalogLive.Detail
- Full spec list with subjective-source breakdown
- Visual bars for numeric fields
- Source citations for subjective ratings
- "Compare this" CTA

## Responsive Design

| Breakpoint | Layout |
|------------|--------|
| ≥1024px | Full multi-column grid with sticky label column |
| <1024px | Horizontal swipe — labels pinned `position: sticky; left: 0; z-index: 10`, columns overflow-x: auto |

## SEO Strategy

### Pre-rendered Routes
- `/product/:slug` — full SSR spec markup
- `/compare/:slugs` — pre-rendered matrix summary

All rendered server-side on first request (not client-only). Subsequent navigation uses LiveView patches.

### Meta Strategy
- Title: `{Product A} vs {Product B} — Side by Side | anything.compare`
- Description: spec-summary sentence
- Canonical URLs, `hreflang` support planned
