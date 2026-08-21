# DraftIQ

DraftIQ is a Vegas-first fantasy-football draft intelligence application. It deliberately separates **true player value** (sportsbook expectations, league scoring, VORP, scarcity), **public draft cost** (ADP), and **pick urgency** (availability, tier breaks, and roster context).

> **Real-data default:** This branch uses persisted provider data by default. Synthetic data is loaded only when `DEMO_MODE=true` is explicitly configured.

## Run locally

```bash
cp .env.example .env
npm install
docker compose up -d db
npx prisma migrate dev --name init
npm run dev
```

`DEMO_MODE=true` explicitly enables the synthetic dataset. With `DEMO_MODE=false`, DraftIQ never falls back to demo players or markets and instead displays a provider warning when real data is unavailable.

For Vercel, configure a serverless PostgreSQL `STORAGE_URL` (for example Neon), run `npm run db:deploy` as a controlled release step, and use `npm run vercel-build`. Docker is optional and is not used by the Vercel runtime.

### Vercel environment variables

Configure the following in both **Preview** and **Production** environments:

- `DEMO_MODE=false`
- `STORAGE_URL=` — authoritative pooled serverless PostgreSQL URL (Neon is supported)
- `SESSION_SECRET=` — at least 32 random characters

Optional provider credentials are `FANTASYPROS_API_KEY` and `SPORTS_GAME_ODDS_API_KEY`. Sleeper and Fantasy Football Calculator do not require credentials. Missing optional credentials reduce model confidence and appear as `NOT CONFIGURED`; they do not prevent league import. Never put provider credentials in variables exposed with a `NEXT_PUBLIC_` prefix.

### First real-league setup

1. Deploy migrations with `npm run db:deploy`.
2. Open **Data Sources** and run **Refresh Players** once.
3. Open **My Leagues**, enter a Sleeper username, and choose a returned league.
4. Verify scoring, managers, rosters, draft order, and keepers; then choose **Save and Set Active**.
5. Dashboard, rankings, planner, simulator, opponent intelligence, and the live draft room now use the persisted active league.

## Architecture

- `app/`, `components/`: fast-decision UI and validated Next.js APIs.
- `providers/`: replaceable normalized provider contracts and Sleeper adapter.
- `services/`: pure scoring, Vegas consensus, availability, tiers, valuation, and simulation engines.
- `jobs/`: scheduled ingestion orchestration with exponential retry.
- `prisma/`: normalized PostgreSQL schema with immutable historical snapshots.
- `tests/`: deterministic quantitative-model tests.

## League intelligence phase

- My Leagues uses the normalized `DraftPlatformProvider` boundary for Sleeper, Yahoo, ESPN, and manual leagues.
- Sleeper imports league scoring, managers, rosters, drafts, keeper picks, and previous-league history through its official public API.
- Stable provider identities power opponent tendencies; limited samples are shrunk toward league behavior before simulation use.
- Manual and synced drafts share a deterministic session domain with pick, edit, undo, pause, availability removal, and recommendation recalculation.
- Yahoo uses server-side OAuth scaffolding. ESPN is explicitly unofficial and accepts only a validated bridge envelope or manual input.
- SportsGameOdds is the optional initial development odds adapter. The vendor-neutral provider boundary reports missing season-long markets as unavailable and never substitutes weekly props or invented coverage.

Provider credentials remain server-side. Production deployments should place ingestion on a scheduler, connect authenticated user sessions, and replace demo adapters through the existing provider interfaces.
