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

Provider credentials remain server-side. Production deployments should place ingestion on a scheduler, connect authenticated user sessions, and replace demo adapters through the existing provider interfaces.
