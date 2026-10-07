// Screenshot Odoo pages from the host. Usage:
//   deno run -A ~/.claude/tools/odoo-shot.mjs <outdir> '<json list of {name, path, js?, wait?}>'
// per-shot extras: cids ("2-3": companies, the ?cids= URL param is ignored), file+fileSel (upload a local file into an input after js)
// env: ODOO_URL (default: IP of goo's `dev` container :8069), ODOO_DB (required), ODOO_LOGIN/ODOO_PASSWORD (admin/admin)
// `js` runs in the page before the shot (e.g. click a menu); `wait` = ms to sleep after load (default 6000).
import puppeteer from "npm:puppeteer-core";
const ip = new TextDecoder().decode(new Deno.Command("docker",{args:["inspect","dev","--format","{{.NetworkSettings.Networks.goo_odoo.IPAddress}}"]}).outputSync().stdout).trim();
const base = Deno.env.get("ODOO_URL") ?? `http://${ip}:8069`;
const db = Deno.env.get("ODOO_DB");
const [outdir, listJson] = Deno.args;
// JSON-RPC login: the login form POST is broken for scripts (KeyError 'login').
const r = await fetch(base+"/web/session/authenticate",{method:"POST",headers:{"Content-Type":"application/json"},
  body:JSON.stringify({jsonrpc:"2.0",method:"call",params:{db,login:Deno.env.get("ODOO_LOGIN")??"admin",password:Deno.env.get("ODOO_PASSWORD")??"admin"}})});
const sid = r.headers.get("set-cookie").match(/session_id=([^;]+)/)[1];
const b = await puppeteer.launch({executablePath:"/usr/bin/chromium",headless:true,
  // insecure-origin flag: Odoo refuses to render over plain http on a non-localhost host
  args:["--no-sandbox",`--unsafely-treat-insecure-origin-as-secure=${base}`],defaultViewport:{width:1600,height:900}});
const p = await b.newPage();
await p.setCookie({name:"session_id",value:sid,url:base});
for (const s of JSON.parse(listJson)) {
  if (s.cids) await p.setCookie({name:"cids",value:s.cids,url:base});
  try {
    await p.goto(base+s.path,{waitUntil:"load",timeout:240000}); // not networkidle: never settles
    await new Promise(r=>setTimeout(r,s.wait??6000));
    if (s.js) { await p.evaluate(s.js); if (s.file) { const h = await p.$(s.fileSel); await h.uploadFile(s.file); } await new Promise(r=>setTimeout(r,1500)); }
    await p.screenshot({path:`${outdir}/${s.name}.png`}); console.log("ok",s.name);
  } catch(e){ console.log("FAIL",s.name,String(e).slice(0,150)); }
}
await b.close();
