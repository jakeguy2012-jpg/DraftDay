import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const migration = readFileSync(
  "prisma/migrations/20260822000000_baseline/migration.sql",
  "utf8",
);
const expectedTables = [
  "User",
  "League",
  "LeagueSettings",
  "Manager",
  "LeagueMember",
  "LeagueSync",
  "Draft",
  "DraftTeam",
  "DraftPick",
  "Roster",
  "Player",
  "PlayerExternalId",
  "ProjectionSnapshot",
  "PlayerProjection",
  "ADPSnapshot",
  "RankingSnapshot",
  "Injury",
  "OddsEvent",
  "PlayerMarket",
  "SportsbookLine",
  "MarketConsensus",
  "VegasProjection",
  "VegasPlayerScore",
  "VegasConfidenceScore",
  "DraftIQScore",
  "PositionTier",
  "AvailabilityEstimate",
  "SimulationRun",
  "SimulationResult",
  "DataProvider",
  "DataIngestionRun",
  "AppPreference",
];

describe("fresh database baseline", () => {
  it("creates every model in the authoritative schema", () => {
    for (const table of expectedTables)
      expect(migration).toContain(`CREATE TABLE "${table}"`);
  });

  it("includes enums, constraints, indexes, and foreign keys", () => {
    expect(migration).toContain('CREATE TYPE "Position"');
    expect(migration).toContain("PRIMARY KEY");
    expect(migration).toContain("CREATE UNIQUE INDEX");
    expect(migration).toContain("FOREIGN KEY");
  });
});
