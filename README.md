# DraftIQ

DraftIQ is a Vegas-first fantasy-football draft intelligence application. It deliberately separates **true player value** (sportsbook expectations, league scoring, VORP, scarcity), **public draft cost** (ADP), and **pick urgency** (availability, tier breaks, and roster context).

> **Draft snapshot:** This branch preserves the initial end-to-end application draft. It runs with clearly labeled synthetic data until real provider credentials and production adapters are configured.

## Run locally

```bash
cp .env.example .env
npm install
docker compose up -d db
npx prisma migrate dev --name init
npm run dev
```

Without provider credentials the application runs in clearly labeled demo mode. Synthetic lines are never presented as live sportsbook data.

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
- OpticOdds is optional and refuses to show invented coverage when credentials or season-long markets are unavailable.

Provider credentials remain server-side. Production deployments should place ingestion on a scheduler, connect authenticated user sessions, and replace demo adapters through the existing provider interfaces.
