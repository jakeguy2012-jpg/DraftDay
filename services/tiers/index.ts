export function assignTiers(values:number[],gap=8){let tier=1;return values.map((value,i)=>{if(i&&values[i-1]-value>=gap)tier++;return tier})}
