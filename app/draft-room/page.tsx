import { LiveDashboard } from "@/components/live-dashboard";import { demoPlayers } from "@/lib/demo";
export default function Page(){return <><div className="sync"><span className="positive">● SLEEPER SYNC HEALTHY</span><small>Last successful sync 18 seconds ago · Manual fallback available</small></div><LiveDashboard initial={demoPlayers}/></>}
