function erf(x:number){const sign=x<0?-1:1,a=Math.abs(x),t=1/(1+.3275911*a);return sign*(1-(((((1.061405429*t-1.453152027)*t)+1.421413741)*t-.284496736)*t+.254829592)*t*Math.exp(-a*a))}
const normalCdf=(z:number)=>(1+erf(z/Math.sqrt(2)))/2;
export function probabilityAvailable(adp:number,sd:number,nextPick:number,runAdjustment=0){return Math.max(0,Math.min(1,1-normalCdf((nextPick-adp+runAdjustment)/Math.max(1,sd))))}
export function nextSnakePick(currentPick:number,teams:number,slot:number){const round=Math.floor((currentPick-1)/teams)+1;for(let r=round;r<=round+2;r++){const pick=(r-1)*teams+(r%2===1?slot:teams-slot+1);if(pick>currentPick)return pick}throw new Error("Unable to determine next pick")}
export function urgency(chanceGone:number,tierBreak=false,scarcity=50,rosterNeed=50){return Math.round(Math.min(100,Math.max(0,chanceGone*65+(tierBreak?15:0)+scarcity*.12+rosterNeed*.08)))}
