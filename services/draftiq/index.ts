import type { PlayerValue } from "@/lib/types";
import { probabilityAvailable,urgency } from "@/services/availability";
export interface Weights {vegas:number;projection:number;vorp:number;scarcity:number;rosterFit:number;injury:number;context:number}
export const VEGAS_FIRST:Weights={vegas:.5,projection:.15,vorp:.15,scarcity:.08,rosterFit:.05,injury:.04,context:.03};
export const vegasEdge=(marketAdp:number,vegasAdp:number)=>marketAdp-vegasAdp;
export const projectionEdge=(vegas:number,fantasy:number)=>fantasy?(vegas-fantasy)/fantasy:0;
export function recommendation(player:PlayerValue,nextPick:number){const available=probabilityAvailable(player.marketAdp,player.adpSd,nextPick),gone=1-available,u=urgency(gone,player.tier===1,Math.min(100,player.vorp),50),edge=vegasEdge(player.marketAdp,player.vegasAdp);let label="STRONG PICK";if(player.draftIq<60||edge<-10)label="FADE";else if(u>=78)label="DRAFT NOW";else if(edge>=12&&available>=.55)label="SAFE TO WAIT";else if(edge>=10)label="PRIORITY TARGET";else if(edge>=4)label="VEGAS VALUE";return {available,gone,urgency:u,edge,label,reason:`Vegas values ${player.name} ${Math.abs(edge).toFixed(1)} picks ${edge>=0?"earlier":"later"} than the public market. ${Math.round(gone*100)}% chance gone before pick ${nextPick}.`}}
