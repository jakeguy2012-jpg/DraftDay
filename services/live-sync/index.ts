import type { NormalizedDraftPick } from "@/providers";
import type { DraftSessionState } from "@/services/draft-session";
import { selectPlayer } from "@/services/draft-session";
export interface PlayerIdentityMap {[externalId:string]:string}
export interface SyncResult {state:DraftSessionState;inserted:number;unresolved:string[];lastSuccessfulSync:Date}
export function applyRemotePicks(state:DraftSessionState,picks:NormalizedDraftPick[],identity:PlayerIdentityMap):SyncResult{let next=state,inserted=0;const unresolved:string[]=[];for(const pick of [...picks].sort((a,b)=>a.pick-b.pick)){if(next.picks.some(p=>p.externalId===pick.externalId))continue;const playerId=identity[pick.playerExternalId];if(!playerId){unresolved.push(pick.playerExternalId);continue}if(next.currentPick!==pick.pick)throw new Error(`Remote pick gap: expected ${next.currentPick}, received ${pick.pick}`);next=selectPlayer(next,playerId,pick.teamExternalId,"SLEEPER",pick.externalId,pick.isKeeper);inserted++}return {state:next,inserted,unresolved,lastSuccessfulSync:new Date()};}
