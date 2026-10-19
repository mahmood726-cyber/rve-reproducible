from pathlib import Path
import re,difflib
for name in ['rve-meta/index.html','shared/rve.js','shared/stats-qt.js']:
 Path('patched',name).write_bytes(Path('original',name).read_bytes())
p=Path('patched/rve-meta/index.html');s=p.read_text(encoding='utf-8')
s=re.sub(r'    <p>Cluster-robust sandwich estimator.*?</p>', '    <p>Cluster-robust meta-regression for dependent effects using the Hedges-Tipton-Johnson CORR working model, CR2 bias-reduced standard errors and per-coefficient Satterthwaite degrees of freedom. Inference can be unreliable with very low degrees of freedom; inspect the coefficient-specific df and sensitivity to the working correlation.</p>',s)
s=s.replace('max="0.99"','max="1"').replace('one fewer than data columns after vi','one per data column after vi')
s=s.replace('      var rows = [];','      var rows = [];\n      var width = null;')
s=s.replace('        var cluster = parts[0];','        if (width === null) width = parts.length;\n        if (parts.length !== width) throw new Error("Row " + (i + 1) + ": inconsistent predictor count");\n        var cluster = parts[0];\n        if (!cluster) throw new Error("Row " + (i + 1) + ": empty cluster");')
s=s.replace('parseFloat(parts[1])','Number(parts[1])').replace('parseFloat(parts[2])','Number(parts[2])').replace('parseFloat(parts[j])','Number(parts[j])')
s=s.replace('if (!isFinite(yi) || !isFinite(vi) || vi <= 0)', 'if (!parts[1].trim() || !parts[2].trim() || !isFinite(yi) || !isFinite(vi) || vi <= 0)')
s=s.replace('warnings.push("Row " + (i + 1) + ": invalid yi/vi"); continue;','throw new Error("Row " + (i + 1) + ": invalid yi/vi");')
s=s.replace('if (!isFinite(v)) { warnings.push("Row " + (i + 1) + ": non-finite predictor"); v = 0; }','if (!parts[j].trim() || !isFinite(v)) throw new Error("Row " + (i + 1) + ": invalid predictor");')
s=s.replace('if (parts.length < 3) { warnings.push("Row " + (i + 1) + ": needs at least cluster, yi, vi"); continue; }','if (parts.length < 3) throw new Error("Row " + (i + 1) + ": needs at least cluster, yi, vi");')
s=s.replace('      var parsed = parseInput(text);','      window.__almLastRVE = null;\n      var parsed;\n      try { parsed = parseInput(text); } catch (e) {\n        document.getElementById("meta-row").textContent = "Fit failed: " + e.message;\n        document.getElementById("coef-body").innerHTML = "";\n        return;\n      }')
s=s.replace('rho: isFinite(rho) ? rho : 0.8','rho: rho')
s=s.replace('      var names = ["(intercept)"].concat(', '      if (summary.some(function (s) { return s.df < 4; })) document.getElementById("meta-row").appendChild(document.createTextNode(" Warning: df < 4; inference may be unreliable."));\n      var names = ["(intercept)"].concat(')
s=s.replace('names[j] + "</td>"','names[j].replace(/[&<>"\']/g, function(c) { return {"&":"&amp;","<":"&lt;",">":"&gt;",\'"\':"&quot;","\'":"&#39;"}[c]; }) + "</td>"')
s=s.replace('the accurate default for inference with few clusters','with potentially unreliable inference at very low degrees of freedom')
s=s.replace('t-quantiles via exact qt (Hill 1970)','t-quantiles via safeguarded inversion of the Student-t CDF')
s=re.sub(r'Calibration: matches .*?rve-meta-cr2-parity.spec.mjs</code>\)\.', 'Reference implementation: <code>robumeta::robu(modelweights="CORR", small=TRUE)</code>. Check numerical conditioning and coefficient-specific degrees of freedom before interpreting inference.',s)
p.write_text(s,encoding='utf-8')
p=Path('patched/shared/rve.js');s=p.read_text(encoding='utf-8')
s=s.replace('    var M = new Array(n);','    var matrixScale = A.reduce(function(max, row) { return Math.max(max, row.reduce(function(m, v) { return Math.max(m, Math.abs(v)); }, 0)); }, 0);\n    if (!(matrixScale > 0) || !Number.isFinite(matrixScale)) throw new Error("RVE: singular X\'WX");\n    var M = new Array(n);')
s=s.replace('Math.abs(M[pivRow][c]) < 1e-12','Math.abs(M[pivRow][c]) < Number.EPSILON * n * matrixScale')
s=s.replace('    var method = (opts.method', '    if (opts.rho !== undefined && (!Number.isFinite(opts.rho) || opts.rho < 0 || opts.rho > 1)) throw new Error("RVE: rho must be in [0, 1]");\n    var method = (opts.method')
s=s.replace('    // Group by cluster', '    rows.forEach(function(r) {\n      if (!r.X || r.X.length !== p || !r.X.every(Number.isFinite) || !Number.isFinite(r.yi) || !Number.isFinite(r.vi) || r.vi <= 0 || r.cluster == null || String(r.cluster).trim() === "") throw new Error("RVE: invalid row or predictor count");\n    });\n\n    // Group by cluster')
s=s.replace('    // Per-cluster size', '    if (m <= p) throw new Error("RVE: m<=p; insufficient clusters for inference");\n\n    // Per-cluster size')
s=s.replace('var clKj = {}, clVbar = {};','var clKj = Object.create(null), clVbar = Object.create(null);')
s=s.replace('    var out = [];\n    for (var j = 0; j < fit.p;', '    if (!qt || !global.AlmStats.pt) throw new Error("RVE: Student-t inference dependency unavailable");\n    var out = [];\n    for (var j = 0; j < fit.p;')
s=s.replace('var crit = qt ? qt(0.975, dfj) : 1.96;','var crit = qt(0.975, dfj);')
start=s.index('      if (global.AlmStats && global.AlmStats.pt) {',s.index('function summary'))
end=s.index('      out.push(',start)
s=s[:start]+'      pval = 2 * global.AlmStats.pt(-Math.abs(tval), dfj);\n'+s[end:]
s=s.replace('var tval = sej > 0 ? est / sej : 0;','var tval = est / sej;')
# robu forms normal equations per cluster before reducing them.
start=s.index('      var XtW = transpose(X)');end=s.index('      var Minv = invert(XtWX);',start)
s=s[:start]+"""      var XtWX = zeros(p,p), Xty = new Array(p).fill(0);
      clusterOrder.forEach(function(key) {
        var idx=byCluster[key], Xj=idx.map(function(i) { return X[i]; });
        var XtW=transpose(Xj).map(function(col) { return col.map(function(v,j) {return v*weights[idx[j]];}); });
        var lhs=matMul(XtW,Xj), rhs=matVec(XtW,idx.map(function(i) {return y[i];}));
        for(var i=0;i<p;i++) { Xty[i]+=rhs[i]; for(var j=0;j<p;j++) XtWX[i][j]+=lhs[i][j]; }
      });
"""+s[end:]
s=s.replace('matVec(Minv, matVec(XtW, y))','matVec(Minv, Xty)')
# Preserve robu's left-associated moment matrix arithmetic.
start=s.index('        var cs = new Array(p);'); end=s.index('      var denom = sumW',start)
s=s[:start]+"""        var Xj=idxj.map(function(i) {return X[i];}), Xt=transpose(Xj);
        var XtW=Xt.map(function(row) {return row.map(function(v) {return v*wj0;});});
        var XtWJ=XtW.map(function(row) {var sum=0;for(var a=0;a<row.length;a++)sum+=row[a];return new Array(kj0).fill(sum);});
        var XWJWX=matMul(XtWJ.map(function(row) {return row.map(function(v) {return v*wj0;});}),Xj);
        var WKXX=matMul(Xt.map(function(row) {return row.map(function(v) {return v*(wj0/kj0);});}),Xj);
        var XtJ=Xt.map(function(row) {var sum=0;for(var a=0;a<row.length;a++)sum+=row[a];return new Array(kj0).fill(sum);});
        var XJX=matMul(XtJ,Xj), XX=matMul(Xt,Xj);
        for(var rr=0;rr<p;rr++)for(var c2=0;c2<p;c2++) {
          sumXWJWX[rr][c2]+=XWJWX[rr][c2];
          MWKXX[rr][c2]+=WKXX[rr][c2];
          MwkXJ[rr][c2]+=(wj0/kj0)*(XJX[rr][c2]-XX[rr][c2]);
        }
      }
"""+s[end:]
# R evaluates the sandwich as successive matrix products, not a score outer product.
start=s.index('        // g_j = w_j'); end=s.index('      }\n      cov = matMul(matMul(Q, meat), Q);',start)
s=s[:start]+"""        var Xj = idxC.map(function(i) { return X[i]; });
        var XtWj = transpose(Xj).map(function(row) { return row.map(function(v) { return v * wj; }); });
        var Sj = idxC.map(function(i) { return idxC.map(function(j) { return resid[i]*resid[j]; }); });
        var block = matMul(matMul(matMul(XtWj, Aj), Sj), Aj);
        block = block.map(function(row) { return row.map(function(v) { return v*wj; }); });
        block = matMul(block, Xj);
        for (var i6=0;i6<p;i6++) for(var j6=0;j6<p;j6++) meat[i6][j6]+=block[i6][j6];
"""+s[end:]
# Match reference guard precedence: attempt the initial design solve first.
s=s.replace('    if (m <= p) throw new Error("RVE: m<=p; insufficient clusters for inference");\n', '')
s=s.replace('    // ---- Re-weighted fit', '    if (m <= p) throw new Error("RVE: m<=p; insufficient clusters for inference");\n\n    // ---- Re-weighted fit')
start=s.index('  function invert(A) {'); end=s.index('  // Symmetric eigendecomposition',start)
s=s[:start]+Path('r2-invert.js').read_text(encoding='utf-8')+'\n'+s[end:]
p.write_text(s,encoding='utf-8')
# Tighten the Student-t incomplete-beta evaluation; solver remains safeguarded.
p=Path('patched/shared/stats-qt.js');s=p.read_text(encoding='utf-8').replace('MAXIT = 200, EPS = 3e-7','MAXIT = 1000, EPS = 4e-15').replace('if (df < 1) return NaN;','if (!(df > 0)) return NaN;').replace('if (df <= 0) return NaN;','if (df <= 0 || Number.isNaN(t) || Number.isNaN(df)) return NaN;');p.write_text(s,encoding='utf-8')
diff=[]
for name in ['rve-meta/index.html','shared/rve.js','shared/stats-qt.js']:
 diff.extend(difflib.unified_diff(Path('original',name).read_text(encoding='utf-8').splitlines(True),Path('patched',name).read_text(encoding='utf-8').splitlines(True),fromfile='a/'+name,tofile='b/'+name))
Path('fix.patch').write_bytes(''.join(diff).encode('utf-8'))
