ALTER TABLE "Player" ADD COLUMN "fantasyPositions" JSONB, ADD COLUMN "injuryStatus" TEXT, ADD COLUMN "metadataSyncedAt" TIMESTAMP(3);
ALTER TABLE "ADPSnapshot" ADD COLUMN "sourceId" TEXT, ADD COLUMN "leagueSize" INTEGER, ADD COLUMN "season" INTEGER;
CREATE INDEX "ADPSnapshot_providerId_season_leagueSize_capturedAt_idx" ON "ADPSnapshot"("providerId","season","leagueSize","capturedAt");
