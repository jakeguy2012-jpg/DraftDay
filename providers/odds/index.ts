import type { OddsProvider } from "@/providers";
import { sportsGameOddsProvider } from "@/providers/odds/sports-game-odds";
export function configuredOddsProvider():OddsProvider|null{const provider=(process.env.ODDS_PROVIDER??"SPORTS_GAME_ODDS").toUpperCase();if(provider==="SPORTS_GAME_ODDS"&&process.env.SPORTS_GAME_ODDS_API_KEY)return sportsGameOddsProvider;return null}
