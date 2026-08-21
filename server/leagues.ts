import { getDb } from "@/lib/db";
import type { NormalizedLeagueProfile } from "@/providers";
import {clearActiveLeague,setActiveLeague} from "@/server/active-league";
import {sleeperLeague} from "@/providers/sleeper";
export interface LeagueSelectionRepository {save(profile:NormalizedLeagueProfile,userId?:string):Promise<{id:string}>}
export async function persistLeagueSelection(profile:NormalizedLeagueProfile,repository:LeagueSelectionRepository,userId?:string){if(!profile.externalId||!profile.name)throw new Error("Invalid league profile");return repository.save(profile,userId)}

async function persistLeaguePrisma(profile:NormalizedLeagueProfile,userId?:string){
  const db=getDb();
  return db.$transaction(async (tx:any)=>{
    const league=await tx.league.upsert({
      where:{provider_externalId_season:{provider:profile.provider,externalId:profile.externalId,season:profile.season}},
      create:{userId,provider:profile.provider,externalId:profile.externalId,season:profile.season,previousLeagueId:profile.previousLeagueId,name:profile.name,settings:{create:{teams:profile.size,draftType:profile.draftType,draftSlot:profile.userDraftSlot??1,scoring:profile.scoring,roster:profile.rosterPositions,keepers:profile.keepers,modelWeights:{preset:"VEGAS_FIRST"}}}},
      update:{name:profile.name,previousLeagueId:profile.previousLeagueId,updatedAt:new Date(),settings:{update:{teams:profile.size,draftType:profile.draftType,draftSlot:profile.userDraftSlot??1,scoring:profile.scoring,roster:profile.rosterPositions,keepers:profile.keepers}}}
    });
    for(const manager of profile.managers){
      const identity=await tx.manager.upsert({where:{provider_externalId:{provider:profile.provider,externalId:manager.externalId}},create:{provider:profile.provider,externalId:manager.externalId,displayName:manager.displayName,avatarUrl:manager.avatarUrl},update:{displayName:manager.displayName,avatarUrl:manager.avatarUrl}});
      const team=profile.teams.find(t=>t.managerExternalId===manager.externalId);
      if(team)await tx.leagueMember.upsert({where:{leagueId_managerId:{leagueId:league.id,managerId:identity.id}},create:{leagueId:league.id,managerId:identity.id,externalTeamId:team.externalId,teamName:team.name,isUser:Boolean(manager.isUser),draftSlot:profile.currentDraft?Number(Object.entries(profile.currentDraft.slotToTeam).find(([,id])=>id===team.externalId)?.[0]):undefined},update:{externalTeamId:team.externalId,teamName:team.name,isUser:Boolean(manager.isUser)}});
    }
    {
      const normalizedDraft=profile.currentDraft,externalDraftId=normalizedDraft?.externalId??`league:${profile.externalId}:pre-draft`,draft=await tx.draft.upsert({where:{platform_externalId:{platform:profile.provider,externalId:externalDraftId}},create:{leagueId:league.id,platform:profile.provider,externalId:externalDraftId,status:normalizedDraft?.status??"PRE_DRAFT",currentPick:(normalizedDraft?.picks.length??0)+1,userSlot:profile.userDraftSlot,rounds:normalizedDraft?.rounds??Math.max(1,profile.rosterPositions.length),lastSyncedAt:normalizedDraft?.lastSyncedAt??profile.lastSyncedAt},update:{status:normalizedDraft?.status??"PRE_DRAFT",currentPick:(normalizedDraft?.picks.length??0)+1,userSlot:profile.userDraftSlot,lastSyncedAt:normalizedDraft?.lastSyncedAt??profile.lastSyncedAt}});
      const sleeper=await tx.dataProvider.findUnique({where:{name_category:{name:"SLEEPER",category:"PLAYER_IDENTITY"}}}),teamIds=new Map<string,string>();
      for(const [teamIndex,team] of profile.teams.entries()){const mappedSlot=normalizedDraft&&Object.entries(normalizedDraft.slotToTeam).find(([,id])=>id===team.externalId)?.[0],slot=Number(mappedSlot??teamIndex+1),saved=await tx.draftTeam.upsert({where:{draftId_slot:{draftId:draft.id,slot}},create:{draftId:draft.id,name:team.name,slot},update:{name:team.name}});teamIds.set(team.externalId,saved.id);if(sleeper){const resolvedPlayerIds:string[]=[];for(const externalId of team.rosterPlayerIds){const identity=await tx.playerExternalId.findUnique({where:{providerId_externalId:{providerId:sleeper.id,externalId}}});if(identity?.playerId){resolvedPlayerIds.push(identity.playerId);await tx.roster.upsert({where:{teamId_playerId:{teamId:saved.id,playerId:identity.playerId}},create:{teamId:saved.id,playerId:identity.playerId,slot:"BENCH"},update:{}})}}await tx.roster.deleteMany({where:{teamId:saved.id,...(resolvedPlayerIds.length?{playerId:{notIn:resolvedPlayerIds}}:{})}})}}
      if(sleeper&&normalizedDraft)for(const pick of normalizedDraft.picks){const identity=await tx.playerExternalId.findUnique({where:{providerId_externalId:{providerId:sleeper.id,externalId:pick.playerExternalId}}}),keeper=profile.keepers.find(value=>value.sourcePickId===pick.externalId||value.playerExternalId===pick.playerExternalId);if(identity?.playerId)await tx.draftPick.upsert({where:{draftId_pick:{draftId:draft.id,pick:pick.pick}},create:{draftId:draft.id,teamId:pick.teamExternalId?teamIds.get(pick.teamExternalId):undefined,playerId:identity.playerId,externalId:pick.externalId,pick:pick.pick,round:keeper?.round??pick.round,slot:pick.slot,isKeeper:Boolean(keeper),source:"SLEEPER",selectedAt:pick.selectedAt},update:{playerId:identity.playerId,teamId:pick.teamExternalId?teamIds.get(pick.teamExternalId):undefined,round:keeper?.round??pick.round,isKeeper:Boolean(keeper)}})}
    }
    await tx.leagueSync.create({data:{leagueId:league.id,provider:profile.provider,status:"SUCCESS",records:profile.managers.length+profile.teams.length+(profile.currentDraft?.picks.length??0),completedAt:new Date()}});
    return league;
  });
}
export async function persistLeague(profile:NormalizedLeagueProfile,userId?:string){return persistLeagueSelection(profile,{save:persistLeaguePrisma},userId)}
export async function myLeagues(){const db=getDb();return db.league.findMany({include:{settings:true,members:{include:{manager:true}},drafts:{orderBy:{createdAt:"desc"},take:1},syncs:{orderBy:{startedAt:"desc"},take:1}},orderBy:{updatedAt:"desc"}})}
export async function leagueProfile(id:string){const db=getDb();return db.league.findUnique({where:{id},include:{settings:true,members:{include:{manager:true}},drafts:{include:{teams:{include:{rosters:{include:{player:true}}}},picks:{include:{player:true}}},orderBy:{createdAt:"desc"}},syncs:{orderBy:{startedAt:"desc"},take:10}}})}
export async function removeLeague(id:string){const db=getDb() as any;await clearActiveLeague(id);return db.league.delete({where:{id}})}
export async function refreshLeague(id:string){const existing:any=await leagueProfile(id);if(!existing)throw new Error("League not found");if(existing.provider!=="SLEEPER")throw new Error(`${existing.provider} refresh is not available`);const userId=existing.members.find((member:any)=>member.isUser)?.manager.externalId,profile=await sleeperLeague(existing.externalId,userId),saved=await persistLeague(profile);return saved}
export async function activateLeague(id:string){return setActiveLeague(id)}
