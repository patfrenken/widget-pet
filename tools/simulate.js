const fs=require('fs');
const src=fs.readFileSync(process.argv[2] || __dirname + '/../package/contents/ui/logic.js','utf8').replace('.pragma library','');
const m={exports:{}}; new Function('module',src)(m); const L=m.exports;
const H=L.HOUR, D=L.DAY;
function run(profile, seedStart){
  let now=Date.UTC(2026,10,16,7,0); // Montag
  let s=L.createEgg(now,null); const opts={timeScale:1,sleepStart:22,sleepEnd:7};
  const log=[];
  let lastCheck=0;
  while(!s.dead && now < Date.UTC(2027,2,1)){
    const d=new Date(now); const hr=d.getHours(); const wd=d.getDay();
    const online = profile.online(hr,wd);
    if(online){
      now+=4*60000; const ev=L.tick(s,now,opts); ev.forEach(e=>log.push([L.ageDays(s),e.type,e.species||e.cause||'']));
      if(now-lastCheck>=profile.every){ lastCheck=now; profile.act(s,now,L); }
    } else { now+=60*60000; } // offline: kein tick -> großer gap
  }
  return {s,log};
}
const workday=(hr,wd)=>hr>=8&&hr<20;
const evening=(hr,wd)=> (wd>=1&&wd<=5)? (hr>=9&&hr<17) : false; // nur Arbeits-PC
const profiles={
  fuersorglich:{online:workday,every:H,act(s,now,L){const asl=L.isAsleep(s,22,7);
    if(s.sick)L.medicine(s); if(s.poop)L.clean(s);
    if(s.hunger<55){ L.feed(s, s.coins>=9?'bento':(s.coins>=3?'apple':'rice'),asl);}
    if(s.fun<65 && L.gameUnlocked(s, 'cuddle')){ const g=s.stage==='adult'?'cafe':s.stage==='teen'?'flap':'cuddle'; L.gameResult(s,g,10,g==='cafe'?25:g==='flap'?10:4,22,now);} }},
  arbeitsPC:{online:evening,every:2*H,act(s,now,L){const asl=L.isAsleep(s,22,7);
    if(s.sick)L.medicine(s); if(s.poop)L.clean(s);
    if(s.hunger<50) L.feed(s, s.coins>=9?'bento':'rice',asl);
    if(s.fun<55 && L.gameUnlocked(s,'cuddle')) L.gameResult(s,'cuddle',8,3,20,now);}},
  gelegentlich:{online:workday,every:8*H,act(s,now,L){ if(s.poop)L.clean(s); if(s.hunger<60)L.feed(s,'rice',false); if(s.sick)L.medicine(s);}},
  gelegentlichSpiel:{online:workday,every:6*H,act(s,now,L){ if(s.poop)L.clean(s); if(s.sick)L.medicine(s); if(s.hunger<60)L.feed(s,s.coins>=9?'bento':'rice',false); if(L.gameUnlocked(s,'cuddle'))L.gameResult(s,'cuddle',8,4,22,now);}},
  vernachlaessigt:{online:workday,every:1e15,act(){}},
};
for(const [n,p] of Object.entries(profiles)){
  const {s,log}=run(p);
  console.log(`\n== ${n}: ${s.dead?'gestorben ('+s.deathCause+')':'lebt'} nach ${L.ageDays(s)} Tagen (${(L.ageDays(s)/7).toFixed(1)} Wo) | Formen ${JSON.stringify(s.species)} | Fehler ${s.totalMistakes} | Münzen ${s.coins}`);
  console.log(log.filter(e=>e[1]!=='poop').map(e=>e.join(':')).join('  '));
}
