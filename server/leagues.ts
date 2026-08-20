import { getDb } from "@/lib/db";
import type { NormalizedLeagueProfile } from "@/providers";

export async function persistLeague(profile:NormalizedLeagueProfile,userId?:string){
  const db=getDb();
  return db.$transaction(async (tx:any)=>{
    const league=await tx.league.upsert({
      where:{provider_externalId_season:{provider:profile.provider,externalId:profile.externalId,season:profile.season}},
      create:{userId,provider:profile.provider,externalId:profile.externalId,season:profile.season,previousLeagueId:profile.previousLeagueId,name:profile.name,settings:{create:{teams:profile.size,draftType:profile.draftType,draftSlot:profile.userDraftSlot??1,scoring:profile.scoring,roster:profile.rosterPositions,modelWeights:{preset:"VEGAS_FIRST"}}}},
      update:{name:profile.name,previousLeagueId:profile.previousLeagueId,updatedAt:new Date(),settings:{update:{teams:profile.size,draftType:profile.draftType,draftSlot:profile.userDraftSlot??1,scoring:profile.scoring,roster:profile.rosterPositions}}}
    });
    for(const manager of profile.managers){
      const identity=await tx.manager.upsert({where:{provider_externalId:{provider:profile.provider,externalId:manager.externalId}},create:{provider:profile.provider,externalId:manager.externalId,displayName:manager.displayName,avatarUrl:manager.avatarUrl},update:{displayName:manager.displayName,avatarUrl:manager.avatarUrl}});
      const team=profile.teams.find(t=>t.managerExternalId===manager.externalId);
      if(team)await tx.leagueMember.upsert({where:{leagueId_managerId:{leagueId:league.id,managerId:identity.id}},create:{leagueId:league.id,managerId:identity.id,externalTeamId:team.externalId,teamName:team.name,isUser:Boolean(manager.isUser),draftSlot:profile.currentDraft?Number(Object.entries(profile.currentDraft.slotToTeam).find(([,id])=>id===team.externalId)?.[0]):undefined},update:{externalTeamId:team.externalId,teamName:team.name,isUser:Boolean(manager.isUser)}});
    }
    if(profile.currentDraft)await tx.draft.upsert({where:{platform_externalId:{platform:profile.provider,externalId:profile.currentDraft.externalId}},create:{leagueId:league.id,platform:profile.provider,externalId:profile.currentDraft.externalId,status:profile.currentDraft.status,currentPick:profile.currentDraft.picks.length+1,userSlot:profile.userDraftSlot,rounds:profile.currentDraft.rounds,lastSyncedAt:profile.currentDraft.lastSyncedAt},update:{status:profile.currentDraft.status,currentPick:profile.currentDraft.picks.length+1,userSlot:profile.userDraftSlot,lastSyncedAt:profile.currentDraft.lastSyncedAt}});
    await tx.leagueSync.create({data:{leagueId:league.id,provider:profile.provider,status:"SUCCESS",records:profile.managers.length+profile.teams.length+(profile.currentDraft?.picks.length??0),completedAt:new Date()}});
    return league;
  });
}
export async function myLeagues(){const db=getDb();return db.league.findMany({include:{settings:true,members:{include:{manager:true}},drafts:{orderBy:{createdAt:"desc"},take:1}},orderBy:{updatedAt:"desc"}})}
export async function leagueProfile(id:string){const db=getDb();return db.league.findUnique({where:{id},include:{settings:true,members:{include:{manager:true}},drafts:{include:{teams:true,picks:{include:{player:true}}},orderBy:{createdAt:"desc"}},syncs:{orderBy:{startedAt:"desc"},take:10}}})}
