import type { DraftPlatformProvider, NormalizedDraft, NormalizedDraftPick, NormalizedLeagueProfile, NormalizedManager, NormalizedTeam } from "@/providers";
import { PPR_SCORING, type ScoringRules } from "@/lib/types";

const base = "https://api.sleeper.app/v1";

export class SleeperProviderError extends Error {
  constructor(public readonly status:number, message:string) { super(message); this.name="SleeperProviderError"; }
}

async function get<T>(path:string):Promise<T> {
  const response=await fetch(`${base}${path}`,{headers:{Accept:"application/json"},next:{revalidate:5}});
  if(!response.ok) throw new SleeperProviderError(response.status,`Sleeper request failed (${response.status})`);
  return response.json() as Promise<T>;
}

type SleeperUser={user_id:string;username:string;display_name?:string;avatar?:string};
type SleeperLeague={league_id:string;previous_league_id?:string;season:string;name:string;total_rosters:number;roster_positions:string[];scoring_settings:Record<string,number>;settings:Record<string,number>;draft_id?:string;status?:string};
type SleeperRoster={roster_id:number;owner_id:string;players?:string[];settings?:{wins?:number;losses?:number}};
type SleeperDraft={draft_id:string;status:string;type?:string;settings:{rounds:number;teams:number};draft_order?:Record<string,number>;slot_to_roster_id?:Record<string,number>};
type SleeperPick={pick_no:number;round:number;draft_slot:number;player_id:string;roster_id?:number;picked_by?:string;metadata?:Record<string,string>;is_keeper?:boolean};

export function normalizeScoring(input:Record<string,number>):ScoringRules { return {...PPR_SCORING,passingYard:input.pass_yd??PPR_SCORING.passingYard,passingTouchdown:input.pass_td??PPR_SCORING.passingTouchdown,interception:input.pass_int??PPR_SCORING.interception,rushingYard:input.rush_yd??PPR_SCORING.rushingYard,rushingTouchdown:input.rush_td??PPR_SCORING.rushingTouchdown,reception:input.rec??0,receivingYard:input.rec_yd??PPR_SCORING.receivingYard,receivingTouchdown:input.rec_td??PPR_SCORING.receivingTouchdown,firstDown:input.bonus_fd??0,tePremium:input.bonus_rec_te??0}; }
export function normalizeUser(user:SleeperUser,currentUserId?:string):NormalizedManager { return {externalId:user.user_id,displayName:user.display_name||user.username,avatarUrl:user.avatar?`https://sleepercdn.com/avatars/${user.avatar}`:undefined,isUser:user.user_id===currentUserId}; }
export function normalizePicks(picks:SleeperPick[]):NormalizedDraftPick[] { return picks.map(p=>({externalId:`${p.pick_no}:${p.player_id}`,pick:p.pick_no,round:p.round,slot:p.draft_slot,playerExternalId:p.player_id,teamExternalId:p.roster_id?String(p.roster_id):p.picked_by,isKeeper:Boolean(p.is_keeper||p.metadata?.is_keeper==="true"),selectedAt:p.metadata?.picked_at?new Date(Number(p.metadata.picked_at)):undefined})); }
export function normalizeDraft(raw:SleeperDraft,picks:SleeperPick[]):NormalizedDraft { const slotToTeam=Object.fromEntries(Object.entries(raw.slot_to_roster_id??{}).map(([slot,roster])=>[Number(slot),String(roster)]));return {externalId:raw.draft_id,status:raw.status==="complete"?"COMPLETE":raw.status==="drafting"?"DRAFTING":"PRE_DRAFT",type:raw.type==="linear"?"LINEAR":"SNAKE",rounds:raw.settings.rounds,slotToTeam,picks:normalizePicks(picks),lastSyncedAt:new Date()}; }
export function normalizeTeams(rosters:SleeperRoster[],users:SleeperUser[]):NormalizedTeam[]{const names=new Map(users.map(u=>[u.user_id,u.display_name||u.username]));return rosters.map(r=>({externalId:String(r.roster_id),name:names.get(r.owner_id)||`Team ${r.roster_id}`,managerExternalId:r.owner_id,rosterPlayerIds:r.players??[],wins:r.settings?.wins,losses:r.settings?.losses}));}

async function hydrateLeague(raw:SleeperLeague,currentUserId?:string):Promise<NormalizedLeagueProfile>{
  const [rawUsers,rosters,rawDrafts]=await Promise.all([get<SleeperUser[]>(`/league/${raw.league_id}/users`),get<SleeperRoster[]>(`/league/${raw.league_id}/rosters`),get<SleeperDraft[]>(`/league/${raw.league_id}/drafts`)]);
  const draftRaw=rawDrafts[0]; const picks=draftRaw?await get<SleeperPick[]>(`/draft/${draftRaw.draft_id}/picks`):[]; const currentDraft=draftRaw?normalizeDraft(draftRaw,picks):undefined;
  const managers=rawUsers.map(u=>normalizeUser(u,currentUserId)); const teams=normalizeTeams(rosters,rawUsers); const keepers=(currentDraft?.picks??[]).filter(p=>p.isKeeper).map(p=>({playerExternalId:p.playerExternalId,teamExternalId:p.teamExternalId??String(p.slot),round:p.round,sourcePickId:p.externalId}));
  const userTeam=teams.find(t=>t.managerExternalId===currentUserId); const userDraftSlot=userTeam&&currentDraft?Number(Object.entries(currentDraft.slotToTeam).find(([,team])=>team===userTeam.externalId)?.[0]):undefined;
  return {provider:"SLEEPER",externalId:raw.league_id,previousLeagueId:raw.previous_league_id&&raw.previous_league_id!=="0"?raw.previous_league_id:undefined,season:Number(raw.season),name:raw.name,size:raw.total_rosters,scoring:normalizeScoring(raw.scoring_settings),rosterPositions:raw.roster_positions,draftType:currentDraft?.type??"SNAKE",userDraftSlot,managers,teams,keepers,currentDraft,historicalDrafts:[],historicalRosters:[],lastSyncedAt:new Date()};
}

export const sleeperProvider:DraftPlatformProvider={name:"Sleeper",user:async username=>normalizeUser(await get<SleeperUser>(`/user/${encodeURIComponent(username)}`)),leagues:async(managerId,season)=>Promise.all((await get<SleeperLeague[]>(`/user/${managerId}/leagues/nfl/${season}`)).map(l=>hydrateLeague(l,managerId))),league:async id=>hydrateLeague(await get<SleeperLeague>(`/league/${id}`)),draft:async id=>normalizeDraft(await get<SleeperDraft>(`/draft/${id}`),await get<SleeperPick[]>(`/draft/${id}/picks`)),picks:async id=>normalizePicks(await get<SleeperPick[]>(`/draft/${id}/picks`))};

export async function leagueHistory(startId:string,maxSeasons=10){const history:NormalizedLeagueProfile[]=[];let id:string|undefined=startId;while(id&&history.length<maxSeasons){const league=await sleeperProvider.league(id);history.push(league);id=league.previousLeagueId}return history;}
