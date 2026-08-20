import type { Position, StatLine } from "@/lib/types";
export interface ProviderContext { season:number; scoring:string; signal?:AbortSignal }
export interface NormalizedPlayer { sourceId:string; name:string; team:string; position:Position; nflId?:string }
export interface FantasyDataProvider { name:string; players(ctx:ProviderContext):Promise<NormalizedPlayer[]> }
export interface ADPProvider { name:string; adp(ctx:ProviderContext):Promise<Array<{sourceId:string;mean:number;sd:number;sampleSize?:number}>> }
export interface ProjectionProvider { name:string; projections(ctx:ProviderContext):Promise<Array<{sourceId:string;stats:StatLine}>> }
export interface InjuryProvider { name:string; injuries(ctx:ProviderContext):Promise<Array<{sourceId:string;status:string;detail?:string}>> }
export interface OddsLine { sourceId:string; book:string; stat:keyof StatLine; line:number; overPrice:number; underPrice:number; marketType:"SEASON"|"WEEKLY"|"FUTURE"; observedAt:Date }
export interface OddsProvider { name:string; lines(ctx:ProviderContext):Promise<OddsLine[]> }
export interface DraftPlatformProvider { name:string; league(id:string):Promise<unknown>; draft(id:string):Promise<unknown>; picks(id:string):Promise<unknown[]> }
