import type { Position, ScoringRules, StatLine } from "@/lib/types";
export interface ProviderContext { season:number; scoring:string; signal?:AbortSignal }
export interface NormalizedPlayer { sourceId:string; name:string; team:string; position:Position; nflId?:string }
export interface FantasyDataProvider { name:string; players(ctx:ProviderContext):Promise<NormalizedPlayer[]> }
export interface ADPProvider { name:string; adp(ctx:ProviderContext):Promise<Array<{sourceId:string;mean:number;sd:number;sampleSize?:number}>> }
export interface ProjectionProvider { name:string; projections(ctx:ProviderContext):Promise<Array<{sourceId:string;stats:StatLine}>> }
export interface InjuryProvider { name:string; injuries(ctx:ProviderContext):Promise<Array<{sourceId:string;status:string;detail?:string}>> }
export interface OddsLine { sourceId:string; book:string; stat:keyof StatLine; line:number; overPrice:number; underPrice:number; marketType:"SEASON"|"WEEKLY"|"FUTURE"; observedAt:Date }
export interface OddsProvider { name:string; lines(ctx:ProviderContext):Promise<OddsLine[]> }
export type DraftProvider = "SLEEPER"|"YAHOO"|"ESPN"|"MANUAL";
export interface NormalizedManager { externalId:string; displayName:string; avatarUrl?:string; isUser?:boolean }
export interface NormalizedTeam { externalId:string; name:string; managerExternalId:string; rosterPlayerIds:string[]; wins?:number; losses?:number }
export interface NormalizedKeeper { playerExternalId:string; teamExternalId:string; round?:number; sourcePickId?:string }
export interface NormalizedDraftPick { externalId:string; pick:number; round:number; slot:number; playerExternalId:string; teamExternalId?:string; isKeeper:boolean; selectedAt?:Date }
export interface NormalizedDraft { externalId:string; status:"PRE_DRAFT"|"DRAFTING"|"COMPLETE"; type:"SNAKE"|"LINEAR"; rounds:number; slotToTeam:Record<number,string>; picks:NormalizedDraftPick[]; lastSyncedAt:Date }
export interface NormalizedLeagueProfile { provider:DraftProvider; externalId:string; previousLeagueId?:string; season:number; name:string; size:number; scoring:ScoringRules; rosterPositions:string[]; draftType:"SNAKE"|"LINEAR"; userDraftSlot?:number; managers:NormalizedManager[]; teams:NormalizedTeam[]; keepers:NormalizedKeeper[]; currentDraft?:NormalizedDraft; historicalDrafts:NormalizedDraft[]; historicalRosters:NormalizedTeam[]; lastSyncedAt:Date }
export interface DraftPlatformProvider {
  name:string;
  user(username:string):Promise<NormalizedManager>;
  leagues(managerExternalId:string,season:number):Promise<NormalizedLeagueProfile[]>;
  league(id:string):Promise<NormalizedLeagueProfile>;
  draft(id:string):Promise<NormalizedDraft>;
  picks(id:string):Promise<NormalizedDraftPick[]>;
}
