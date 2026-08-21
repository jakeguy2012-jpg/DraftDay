CREATE TABLE "AppPreference" ("id" TEXT NOT NULL DEFAULT 'default', "activeLeagueId" TEXT, "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "AppPreference_pkey" PRIMARY KEY ("id"));
CREATE INDEX "AppPreference_activeLeagueId_idx" ON "AppPreference"("activeLeagueId");
ALTER TABLE "LeagueSettings" ADD COLUMN "keepers" JSONB;
