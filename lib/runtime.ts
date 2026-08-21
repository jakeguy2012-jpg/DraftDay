export function isDemoMode(env:NodeJS.ProcessEnv=process.env){return env.DEMO_MODE?.trim().toLowerCase()==="true"}
export function requireRealData(){if(isDemoMode())throw new Error("Real-data operation is disabled while DEMO_MODE=true")}
