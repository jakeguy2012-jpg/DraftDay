-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Position" AS ENUM ('QB', 'RB', 'WR', 'TE', 'K', 'DST');

-- CreateEnum
CREATE TYPE "DraftType" AS ENUM ('SNAKE', 'LINEAR');

-- CreateEnum
CREATE TYPE "MarketType" AS ENUM ('SEASON', 'WEEKLY', 'FUTURE', 'TEAM');

-- CreateEnum
CREATE TYPE "MappingStatus" AS ENUM ('RESOLVED', 'AMBIGUOUS', 'UNRESOLVED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "League" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "provider" TEXT NOT NULL DEFAULT 'MANUAL',
    "externalId" TEXT,
    "season" INTEGER NOT NULL DEFAULT 2026,
    "previousLeagueId" TEXT,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "League_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeagueSettings" (
    "id" TEXT NOT NULL,
    "leagueId" TEXT NOT NULL,
    "teams" INTEGER NOT NULL,
    "draftType" "DraftType" NOT NULL,
    "draftSlot" INTEGER NOT NULL,
    "scoring" JSONB NOT NULL,
    "roster" JSONB NOT NULL,
    "keepers" JSONB,
    "modelWeights" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LeagueSettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Draft" (
    "id" TEXT NOT NULL,
    "leagueId" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "externalId" TEXT,
    "status" TEXT NOT NULL DEFAULT 'PAUSED',
    "currentPick" INTEGER NOT NULL DEFAULT 1,
    "userSlot" INTEGER,
    "rounds" INTEGER NOT NULL DEFAULT 16,
    "lastSyncedAt" TIMESTAMP(3),
    "syncError" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Draft_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DraftTeam" (
    "id" TEXT NOT NULL,
    "draftId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slot" INTEGER NOT NULL,

    CONSTRAINT "DraftTeam_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DraftPick" (
    "id" TEXT NOT NULL,
    "draftId" TEXT NOT NULL,
    "teamId" TEXT,
    "playerId" TEXT NOT NULL,
    "externalId" TEXT,
    "pick" INTEGER NOT NULL,
    "round" INTEGER NOT NULL,
    "slot" INTEGER,
    "isKeeper" BOOLEAN NOT NULL DEFAULT false,
    "source" TEXT NOT NULL DEFAULT 'MANUAL',
    "selectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DraftPick_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Roster" (
    "id" TEXT NOT NULL,
    "teamId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "slot" TEXT NOT NULL,
    "isStarter" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Roster_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Player" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "normalizedName" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "team" TEXT NOT NULL,
    "position" "Position" NOT NULL,
    "fantasyPositions" JSONB,
    "byeWeek" INTEGER,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "injuryStatus" TEXT,
    "metadataSyncedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlayerExternalId" (
    "id" TEXT NOT NULL,
    "playerId" TEXT,
    "providerId" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "sourceName" TEXT,
    "status" "MappingStatus" NOT NULL,
    "confidence" DOUBLE PRECISION,
    "candidates" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PlayerExternalId_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectionSnapshot" (
    "id" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "season" INTEGER NOT NULL,
    "scoring" TEXT NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProjectionSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlayerProjection" (
    "id" TEXT NOT NULL,
    "snapshotId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "stats" JSONB NOT NULL,
    "fantasyPoints" DOUBLE PRECISION NOT NULL,
    "floor" DOUBLE PRECISION,
    "ceiling" DOUBLE PRECISION,

    CONSTRAINT "PlayerProjection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ADPSnapshot" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "sourceId" TEXT,
    "scoring" TEXT NOT NULL,
    "leagueType" TEXT NOT NULL,
    "leagueSize" INTEGER,
    "season" INTEGER,
    "mean" DOUBLE PRECISION NOT NULL,
    "deviation" DOUBLE PRECISION NOT NULL,
    "sampleSize" INTEGER,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ADPSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RankingSnapshot" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "scoring" TEXT NOT NULL,
    "rank" INTEGER NOT NULL,
    "positionRank" INTEGER NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RankingSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Injury" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "detail" TEXT,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Injury_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OddsEvent" (
    "id" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "startsAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OddsEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PlayerMarket" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "stat" TEXT NOT NULL,
    "marketType" "MarketType" NOT NULL,

    CONSTRAINT "PlayerMarket_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SportsbookLine" (
    "id" TEXT NOT NULL,
    "marketId" TEXT NOT NULL,
    "sportsbook" TEXT NOT NULL,
    "line" DOUBLE PRECISION NOT NULL,
    "overPrice" INTEGER NOT NULL,
    "underPrice" INTEGER NOT NULL,
    "source" TEXT NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SportsbookLine_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MarketConsensus" (
    "id" TEXT NOT NULL,
    "marketId" TEXT NOT NULL,
    "mean" DOUBLE PRECISION NOT NULL,
    "median" DOUBLE PRECISION NOT NULL,
    "weighted" DOUBLE PRECISION NOT NULL,
    "dispersion" DOUBLE PRECISION NOT NULL,
    "bookCount" INTEGER NOT NULL,
    "outlierCount" INTEGER NOT NULL,
    "confidence" DOUBLE PRECISION NOT NULL,
    "lineMovement" DOUBLE PRECISION,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MarketConsensus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VegasProjection" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "scoring" TEXT NOT NULL,
    "stats" JSONB NOT NULL,
    "fantasyPoints" DOUBLE PRECISION NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VegasProjection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VegasPlayerScore" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "scoring" TEXT NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "components" JSONB NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VegasPlayerScore_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "VegasConfidenceScore" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "breadth" DOUBLE PRECISION NOT NULL,
    "agreement" DOUBLE PRECISION NOT NULL,
    "freshness" DOUBLE PRECISION NOT NULL,
    "keyMarkets" DOUBLE PRECISION NOT NULL,
    "pricing" DOUBLE PRECISION NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VegasConfidenceScore_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DraftIQScore" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "scoring" TEXT NOT NULL,
    "overall" DOUBLE PRECISION NOT NULL,
    "vegasScore" DOUBLE PRECISION NOT NULL,
    "projectionScore" DOUBLE PRECISION NOT NULL,
    "vorpScore" DOUBLE PRECISION NOT NULL,
    "scarcityScore" DOUBLE PRECISION NOT NULL,
    "rosterFitScore" DOUBLE PRECISION NOT NULL,
    "injuryScore" DOUBLE PRECISION NOT NULL,
    "vegasConfidence" DOUBLE PRECISION NOT NULL,
    "vegasAdp" DOUBLE PRECISION NOT NULL,
    "marketAdp" DOUBLE PRECISION NOT NULL,
    "vegasEdge" DOUBLE PRECISION NOT NULL,
    "components" JSONB NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DraftIQScore_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PositionTier" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "scoring" TEXT NOT NULL,
    "tier" INTEGER NOT NULL,
    "value" DOUBLE PRECISION NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PositionTier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AvailabilityEstimate" (
    "id" TEXT NOT NULL,
    "playerId" TEXT NOT NULL,
    "draftId" TEXT,
    "currentPick" INTEGER NOT NULL,
    "targetPick" INTEGER NOT NULL,
    "probability" DOUBLE PRECISION NOT NULL,
    "modelVersion" TEXT NOT NULL,
    "inputs" JSONB NOT NULL,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AvailabilityEstimate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SimulationRun" (
    "id" TEXT NOT NULL,
    "draftId" TEXT,
    "iterations" INTEGER NOT NULL,
    "depth" INTEGER NOT NULL,
    "settings" JSONB NOT NULL,
    "status" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "SimulationRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SimulationResult" (
    "id" TEXT NOT NULL,
    "runId" TEXT NOT NULL,
    "candidateId" TEXT NOT NULL,
    "survivalRate" DOUBLE PRECISION NOT NULL,
    "expectedStarterPoints" DOUBLE PRECISION NOT NULL,
    "expectedVorp" DOUBLE PRECISION NOT NULL,
    "expectedVegasEdge" DOUBLE PRECISION NOT NULL,
    "composition" JSONB NOT NULL,

    CONSTRAINT "SimulationResult_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DataProvider" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "configuration" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DataProvider_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DataIngestionRun" (
    "id" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "calls" INTEGER NOT NULL DEFAULT 0,
    "records" INTEGER NOT NULL DEFAULT 0,
    "failures" INTEGER NOT NULL DEFAULT 0,
    "quotaRemaining" INTEGER,
    "quotaResetAt" TIMESTAMP(3),
    "error" TEXT,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "DataIngestionRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Manager" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "externalId" TEXT NOT NULL,
    "displayName" TEXT NOT NULL,
    "avatarUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Manager_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeagueMember" (
    "id" TEXT NOT NULL,
    "leagueId" TEXT NOT NULL,
    "managerId" TEXT NOT NULL,
    "externalTeamId" TEXT NOT NULL,
    "teamName" TEXT NOT NULL,
    "draftSlot" INTEGER,
    "isUser" BOOLEAN NOT NULL DEFAULT false,
    "tendency" JSONB,
    "sampleSize" INTEGER NOT NULL DEFAULT 0,
    "confidence" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LeagueMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LeagueSync" (
    "id" TEXT NOT NULL,
    "leagueId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "records" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "LeagueSync_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AppPreference" (
    "id" TEXT NOT NULL DEFAULT 'default',
    "activeLeagueId" TEXT,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AppPreference_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "League_provider_externalId_season_key" ON "League"("provider", "externalId", "season");

-- CreateIndex
CREATE UNIQUE INDEX "LeagueSettings_leagueId_key" ON "LeagueSettings"("leagueId");

-- CreateIndex
CREATE INDEX "Draft_leagueId_status_idx" ON "Draft"("leagueId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Draft_platform_externalId_key" ON "Draft"("platform", "externalId");

-- CreateIndex
CREATE UNIQUE INDEX "DraftTeam_draftId_slot_key" ON "DraftTeam"("draftId", "slot");

-- CreateIndex
CREATE INDEX "DraftPick_draftId_playerId_idx" ON "DraftPick"("draftId", "playerId");

-- CreateIndex
CREATE UNIQUE INDEX "DraftPick_draftId_pick_key" ON "DraftPick"("draftId", "pick");

-- CreateIndex
CREATE UNIQUE INDEX "DraftPick_draftId_externalId_key" ON "DraftPick"("draftId", "externalId");

-- CreateIndex
CREATE UNIQUE INDEX "Roster_teamId_playerId_key" ON "Roster"("teamId", "playerId");

-- CreateIndex
CREATE INDEX "Player_normalizedName_team_position_idx" ON "Player"("normalizedName", "team", "position");

-- CreateIndex
CREATE INDEX "PlayerExternalId_status_idx" ON "PlayerExternalId"("status");

-- CreateIndex
CREATE UNIQUE INDEX "PlayerExternalId_providerId_externalId_key" ON "PlayerExternalId"("providerId", "externalId");

-- CreateIndex
CREATE INDEX "ProjectionSnapshot_season_scoring_capturedAt_idx" ON "ProjectionSnapshot"("season", "scoring", "capturedAt");

-- CreateIndex
CREATE UNIQUE INDEX "PlayerProjection_snapshotId_playerId_key" ON "PlayerProjection"("snapshotId", "playerId");

-- CreateIndex
CREATE INDEX "ADPSnapshot_playerId_scoring_capturedAt_idx" ON "ADPSnapshot"("playerId", "scoring", "capturedAt");

-- CreateIndex
CREATE INDEX "ADPSnapshot_providerId_season_leagueSize_capturedAt_idx" ON "ADPSnapshot"("providerId", "season", "leagueSize", "capturedAt");

-- CreateIndex
CREATE INDEX "RankingSnapshot_playerId_capturedAt_idx" ON "RankingSnapshot"("playerId", "capturedAt");

-- CreateIndex
CREATE INDEX "Injury_playerId_capturedAt_idx" ON "Injury"("playerId", "capturedAt");

-- CreateIndex
CREATE UNIQUE INDEX "OddsEvent_providerId_externalId_key" ON "OddsEvent"("providerId", "externalId");

-- CreateIndex
CREATE INDEX "PlayerMarket_playerId_stat_marketType_idx" ON "PlayerMarket"("playerId", "stat", "marketType");

-- CreateIndex
CREATE INDEX "SportsbookLine_marketId_capturedAt_idx" ON "SportsbookLine"("marketId", "capturedAt");

-- CreateIndex
CREATE INDEX "MarketConsensus_marketId_capturedAt_idx" ON "MarketConsensus"("marketId", "capturedAt");

-- CreateIndex
CREATE INDEX "VegasProjection_playerId_scoring_capturedAt_idx" ON "VegasProjection"("playerId", "scoring", "capturedAt");

-- CreateIndex
CREATE INDEX "VegasPlayerScore_playerId_scoring_capturedAt_idx" ON "VegasPlayerScore"("playerId", "scoring", "capturedAt");

-- CreateIndex
CREATE INDEX "VegasConfidenceScore_playerId_capturedAt_idx" ON "VegasConfidenceScore"("playerId", "capturedAt");

-- CreateIndex
CREATE INDEX "DraftIQScore_scoring_overall_capturedAt_idx" ON "DraftIQScore"("scoring", "overall", "capturedAt");

-- CreateIndex
CREATE INDEX "PositionTier_scoring_tier_capturedAt_idx" ON "PositionTier"("scoring", "tier", "capturedAt");

-- CreateIndex
CREATE INDEX "AvailabilityEstimate_draftId_currentPick_idx" ON "AvailabilityEstimate"("draftId", "currentPick");

-- CreateIndex
CREATE UNIQUE INDEX "SimulationResult_runId_candidateId_key" ON "SimulationResult"("runId", "candidateId");

-- CreateIndex
CREATE UNIQUE INDEX "DataProvider_name_category_key" ON "DataProvider"("name", "category");

-- CreateIndex
CREATE INDEX "DataIngestionRun_providerId_startedAt_idx" ON "DataIngestionRun"("providerId", "startedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Manager_provider_externalId_key" ON "Manager"("provider", "externalId");

-- CreateIndex
CREATE INDEX "LeagueMember_managerId_idx" ON "LeagueMember"("managerId");

-- CreateIndex
CREATE UNIQUE INDEX "LeagueMember_leagueId_managerId_key" ON "LeagueMember"("leagueId", "managerId");

-- CreateIndex
CREATE INDEX "LeagueSync_leagueId_startedAt_idx" ON "LeagueSync"("leagueId", "startedAt");

-- CreateIndex
CREATE INDEX "AppPreference_activeLeagueId_idx" ON "AppPreference"("activeLeagueId");

-- AddForeignKey
ALTER TABLE "League" ADD CONSTRAINT "League_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeagueSettings" ADD CONSTRAINT "LeagueSettings_leagueId_fkey" FOREIGN KEY ("leagueId") REFERENCES "League"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Draft" ADD CONSTRAINT "Draft_leagueId_fkey" FOREIGN KEY ("leagueId") REFERENCES "League"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DraftTeam" ADD CONSTRAINT "DraftTeam_draftId_fkey" FOREIGN KEY ("draftId") REFERENCES "Draft"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DraftPick" ADD CONSTRAINT "DraftPick_draftId_fkey" FOREIGN KEY ("draftId") REFERENCES "Draft"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DraftPick" ADD CONSTRAINT "DraftPick_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "DraftTeam"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roster" ADD CONSTRAINT "Roster_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerExternalId" ADD CONSTRAINT "PlayerExternalId_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerExternalId" ADD CONSTRAINT "PlayerExternalId_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectionSnapshot" ADD CONSTRAINT "ProjectionSnapshot_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerProjection" ADD CONSTRAINT "PlayerProjection_snapshotId_fkey" FOREIGN KEY ("snapshotId") REFERENCES "ProjectionSnapshot"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerProjection" ADD CONSTRAINT "PlayerProjection_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ADPSnapshot" ADD CONSTRAINT "ADPSnapshot_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ADPSnapshot" ADD CONSTRAINT "ADPSnapshot_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RankingSnapshot" ADD CONSTRAINT "RankingSnapshot_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RankingSnapshot" ADD CONSTRAINT "RankingSnapshot_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Injury" ADD CONSTRAINT "Injury_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Injury" ADD CONSTRAINT "Injury_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OddsEvent" ADD CONSTRAINT "OddsEvent_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerMarket" ADD CONSTRAINT "PlayerMarket_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "OddsEvent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PlayerMarket" ADD CONSTRAINT "PlayerMarket_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SportsbookLine" ADD CONSTRAINT "SportsbookLine_marketId_fkey" FOREIGN KEY ("marketId") REFERENCES "PlayerMarket"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MarketConsensus" ADD CONSTRAINT "MarketConsensus_marketId_fkey" FOREIGN KEY ("marketId") REFERENCES "PlayerMarket"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VegasProjection" ADD CONSTRAINT "VegasProjection_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VegasPlayerScore" ADD CONSTRAINT "VegasPlayerScore_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VegasConfidenceScore" ADD CONSTRAINT "VegasConfidenceScore_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DraftIQScore" ADD CONSTRAINT "DraftIQScore_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PositionTier" ADD CONSTRAINT "PositionTier_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AvailabilityEstimate" ADD CONSTRAINT "AvailabilityEstimate_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SimulationRun" ADD CONSTRAINT "SimulationRun_draftId_fkey" FOREIGN KEY ("draftId") REFERENCES "Draft"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SimulationResult" ADD CONSTRAINT "SimulationResult_runId_fkey" FOREIGN KEY ("runId") REFERENCES "SimulationRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DataIngestionRun" ADD CONSTRAINT "DataIngestionRun_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "DataProvider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeagueMember" ADD CONSTRAINT "LeagueMember_leagueId_fkey" FOREIGN KEY ("leagueId") REFERENCES "League"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeagueMember" ADD CONSTRAINT "LeagueMember_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "Manager"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LeagueSync" ADD CONSTRAINT "LeagueSync_leagueId_fkey" FOREIGN KEY ("leagueId") REFERENCES "League"("id") ON DELETE CASCADE ON UPDATE CASCADE;
