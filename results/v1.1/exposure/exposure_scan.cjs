// node exposure_scan.cjs exposure.tsv <engine rve.js>
// Per family: values, R levels, partition conflicts (values whose engine group
// differs, as a set, from their R level) for the previous rule
// Number(c.toPrecision(15)) and for the fixed rFactorLevels, plus label
// mismatches against as.character for the fixed rule.
const fs = require('fs');
const RVE = require(require('path').resolve(process.argv[3]));
const { rFactorLevels, rAsCharacterDouble } = RVE._reductions;
const old = c => String(Number(c.toPrecision(15)));
const fixedGroup = xs => rFactorLevels(xs).map(l => l.group);
const fam = new Map();
for (const line of fs.readFileSync(process.argv[2], 'utf8').split('\n')) {
  if (!line) continue;
  const [family, vid, x, rs, code] = line.split('\t');
  if (!fam.has(family)) fam.set(family, new Map());
  const vs = fam.get(family);
  if (!vs.has(vid)) vs.set(vid, []);
  vs.get(vid).push({ x: Number(x), rs, code: Number(code) });
}
function conflicts(groups, codes) {
  const g = new Map(), c = new Map();
  groups.forEach((k, i) => { if (!g.has(k)) g.set(k, []); g.get(k).push(i); });
  codes.forEach((k, i) => { if (!c.has(k)) c.set(k, []); c.get(k).push(i); });
  let n = 0;
  groups.forEach((k, i) => { if (g.get(k).join() !== c.get(codes[i]).join()) n++; });
  return { n, levels: g.size };
}
const rows = [];
for (const [family, vs] of fam) {
  let n = 0, rLevels = 0, oldC = 0, oldLv = 0, newC = 0, newLv = 0, labels = 0;
  for (const v of vs.values()) {
    const xs = v.map(e => e.x), codes = v.map(e => e.code);
    n += xs.length; rLevels += new Set(codes).size;
    const o = conflicts(xs.map(old), codes), f = conflicts(fixedGroup(xs), codes);
    oldC += o.n; oldLv += o.levels; newC += f.n; newLv += f.levels;
    v.forEach(e => { if (rAsCharacterDouble(e.x) !== e.rs) labels++; });
  }
  rows.push({ family, vectors: vs.size, n, rLevels, oldLv, oldC, newLv, newC, labels });
}
console.log('| ID shape | vectors | values | R levels | previous rule: levels | previous rule: conflicts | fixed: levels | fixed: conflicts | fixed: as.character mismatches |');
console.log('|---|---:|---:|---:|---:|---:|---:|---:|---:|');
for (const r of rows) console.log(`| ${r.family} | ${r.vectors} | ${r.n} | ${r.rLevels} | ${r.oldLv} | ${r.oldC} | ${r.newLv} | **${r.newC}** | ${r.labels} |`);
const t = rows.reduce((a, r) => ({ n: a.n + r.n, c: a.c + r.newC, l: a.l + r.labels }), { n: 0, c: 0, l: 0 });
console.log(`\nTOTAL values ${t.n}; fixed-rule partition conflicts ${t.c}; as.character mismatches ${t.l}`);
