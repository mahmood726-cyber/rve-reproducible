// Engine-level planted defects (review m5). Each variant changes one thing in a
// copy of shared/rve.js; the Node suites then run against it via RVE_ENGINE.
// node plant_engine_defects.cjs  ->  planted-engine-defects.json / .log
'use strict';
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const {spawnSync} = require('child_process');
const root = path.resolve(__dirname, '../..');
const source = fs.readFileSync(path.join(root, 'shared/rve.js'), 'utf8');
const plants = {
  'naive-mean': ['function rMean(xs) {',
    'function rMean(xs) { return xs.reduce(function(a, b) { return a + b; }, 0) / xs.length;'],
  'string-sort-numeric-ids': ['var numeric = clusters.every(function(c) { return typeof c === "number"; });',
    'var numeric = false; clusters = clusters.map(String);'],
  'first-seen-order': ['inputOrder.sort(function(a, b) { return a.key < b.key ? -1 : a.key > b.key ? 1 : a.index - b.index; });',
    '/* planted: no sort, clusters in first-seen order */'],
};
const suites = ['rve-meta/tests/r-reductions.node.cjs', 'rve-meta/tests/p15-eigen.node.cjs'];
function run(engine) {
  const r = spawnSync(process.execPath, ['--test', '--test-reporter=tap', ...suites],
    {cwd: root, env: {...process.env, RVE_ENGINE: engine}, encoding: 'utf8'});
  const lines = r.stdout.split('\n');
  const results = lines.map(l => l.match(/^(not ok|ok) \d+ - (.*)$/)).filter(Boolean)
    .map(m => ({test: m[2].trim(), passed: m[1] === 'ok'}));
  return {exit: r.status, results, failed: results.filter(x => !x.passed).map(x => x.test)};
}
const out = {engine_sha256: crypto.createHash('sha256').update(source).digest('hex'), suites, variants: {}};
out.control = run(path.join(root, 'shared/rve.js'));
for (const [name, [from, to]] of Object.entries(plants)) {
  if (source.split(from).length !== 2) throw new Error(`${name}: anchor not found exactly once`);
  const dir = path.join(__dirname, 'planted-engines', name);
  fs.mkdirSync(dir, {recursive: true});
  // audit/package.json declares ES modules; the engine copies are CommonJS.
  fs.writeFileSync(path.join(__dirname, 'planted-engines', 'package.json'), '{"type": "commonjs"}\n');
  fs.copyFileSync(path.join(root, 'shared/rve-eigen.js'), path.join(dir, 'rve-eigen.js'));
  fs.writeFileSync(path.join(dir, 'rve.js'), source.replace(from, to));
  out.variants[name] = {replaced: from, with: to, ...run(path.join(dir, 'rve.js'))};
}
fs.writeFileSync(path.join(__dirname, 'planted-engine-defects.json'), JSON.stringify(out, null, 2) + '\n');
const log = [`control: ${out.control.results.length} tests, failed ${out.control.failed.length}`];
for (const [name, v] of Object.entries(out.variants))
  log.push(`${name}: ${v.results.length} tests, failed ${v.failed.length}: ${v.failed.join(' | ')}`);
fs.writeFileSync(path.join(__dirname, 'planted-engine-defects.log'), log.join('\n') + '\n');
console.log(log.join('\n'));
