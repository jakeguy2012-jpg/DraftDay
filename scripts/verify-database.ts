import { getDb } from "@/lib/db";
import { PPR_SCORING } from "@/lib/types";
import type { NormalizedLeagueProfile } from "@/providers";
import {
  clearActiveLeague,
  getActiveLeague,
  setActiveLeague,
} from "@/server/active-league";
import { persistLeague } from "@/server/leagues";

async function main() {
  const db = getDb();
  const suffix = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  let leagueId: string | undefined;
  let providerId: string | undefined;

  const profile: NormalizedLeagueProfile = {
    provider: "SLEEPER",
    externalId: `database-verification-${suffix}`,
    season: new Date().getUTCFullYear(),
    name: "DraftIQ Database Verification",
    size: 2,
    scoring: PPR_SCORING,
    rosterPositions: ["QB", "RB", "WR", "TE", "FLEX", "BN"],
    draftType: "SNAKE",
    userDraftSlot: 1,
    managers: [
      {
        externalId: `manager-${suffix}`,
        displayName: "Verification Manager",
        isUser: true,
      },
    ],
    teams: [
      {
        externalId: `team-${suffix}`,
        managerExternalId: `manager-${suffix}`,
        name: "Verification Team",
        rosterPlayerIds: [],
      },
    ],
    keepers: [],
    historicalDrafts: [],
    historicalRosters: [],
    lastSyncedAt: new Date(),
  };

  try {
    const provider = await db.dataProvider.upsert({
      where: {
        name_category: { name: "DATABASE_VERIFICATION", category: suffix },
      },
      create: {
        name: "DATABASE_VERIFICATION",
        category: suffix,
        enabled: false,
      },
      update: { enabled: false },
    });
    providerId = provider.id;

    const league = await persistLeague(profile);
    leagueId = league.id;
    await setActiveLeague(league.id);
    const reloaded = await getActiveLeague();

    if (!reloaded?.settings || reloaded.id !== league.id) {
      throw new Error("Active league could not be reloaded with its settings");
    }
    if (
      !reloaded.members.some((member: { isUser: boolean }) => member.isUser)
    ) {
      throw new Error(
        "Sleeper manager and league membership were not persisted",
      );
    }

    console.log(`Database verification passed for ${reloaded.name}.`);
  } finally {
    if (leagueId) {
      await clearActiveLeague(leagueId);
      await db.league
        .delete({ where: { id: leagueId } })
        .catch(() => undefined);
    }
    if (providerId) {
      await db.dataProvider
        .delete({ where: { id: providerId } })
        .catch(() => undefined);
    }
    await db.$disconnect();
  }
}

main().catch((error) => {
  console.error(
    error instanceof Error ? error.message : "Database verification failed",
  );
  process.exitCode = 1;
});
