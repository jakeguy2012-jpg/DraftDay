import "./globals.css";
import Link from "next/link";
export const metadata={title:"DraftIQ — Vegas-First Draft Intelligence",description:"Find fantasy draft mispricing using sportsbook expectations."};
const nav=[["/","Dashboard"],["/leagues","My Leagues"],["/draft-room","Live Draft Room"],["/opponent-intel","Opponent Intel"],["/vegas-board","Vegas Board"],["/rankings","Rankings"],["/planner","Draft Planner"],["/simulator","Simulator"],["/data-sources","Data Sources"],["/settings","Settings"],["/admin/mapping","Player Mapping"]];
export default function Layout({children}:{children:React.ReactNode}){return <html lang="en"><body><aside><div className="brand"><span>DIQ</span><div>Draft<b>IQ</b><small>VEGAS-FIRST INTELLIGENCE</small></div></div><nav>{nav.map(([href,label])=><Link key={href} href={href}>{label}</Link>)}</nav><div className="source"><i/> DEMO DATA<small>Synthetic markets · clearly labeled</small></div></aside><main>{children}</main></body></html>}
