import {NextResponse} from "next/server";import {demoPlayers} from "@/lib/demo";import {z} from "zod";
const query=z.object({position:z.enum(["QB","RB","WR","TE","K","DST"]).optional()});
export async function GET(request:Request){const parsed=query.safeParse(Object.fromEntries(new URL(request.url).searchParams));if(!parsed.success)return NextResponse.json({error:"Invalid query",issues:parsed.error.issues},{status:400});return NextResponse.json({data:demoPlayers.filter(p=>!parsed.data.position||p.position===parsed.data.position),meta:{demo:true,updatedAt:new Date().toISOString()}})}
