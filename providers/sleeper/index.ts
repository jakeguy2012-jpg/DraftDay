import type { DraftPlatformProvider } from "@/providers";
const base="https://api.sleeper.app/v1";
async function get(path:string){const response=await fetch(`${base}${path}`,{next:{revalidate:5}});if(!response.ok)throw new Error(`Sleeper ${response.status}`);return response.json()}
export const sleeperProvider:DraftPlatformProvider={name:"Sleeper",league:id=>get(`/league/${id}`),draft:id=>get(`/draft/${id}`),picks:id=>get(`/draft/${id}/picks`)};
