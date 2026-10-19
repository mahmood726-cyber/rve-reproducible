  // Partial-pivot LU, followed by triangular solves (R solve.default/dgesv order).
  function invert(A) {
    var n=A.length, LU=A.map(r=>r.slice()), piv=[];
    for(var k=0;k<n;k++) {
      var pivot=k;
      for(var i=k+1;i<n;i++) if(Math.abs(LU[i][k])>Math.abs(LU[pivot][k])) pivot=i;
      if(LU[pivot][k]===0 || !Number.isFinite(LU[pivot][k])) throw new Error("RVE: singular X'WX");
      piv.push(pivot);
      if(pivot!==k) {var tmp=LU[k];LU[k]=LU[pivot];LU[pivot]=tmp;}
      for(var i=k+1;i<n;i++) LU[i][k]*=(1/LU[k][k]);
      for(var j=k+1;j<n;j++) for(var i=k+1;i<n;i++) LU[i][j]-=LU[i][k]*LU[k][j];
    }
    var out=identity(n);
    for(var k=0;k<n;k++) if(piv[k]!==k) {var tmp=out[k];out[k]=out[piv[k]];out[piv[k]]=tmp;}
    for(var col=0;col<n;col++) {
      for(var k=0;k<n;k++) for(var i=k+1;i<n;i++) out[i][col]-=out[k][col]*LU[i][k];
      for(var k=n-1;k>=0;k--) {
        out[k][col]/=LU[k][k];
        for(var i=0;i<k;i++) out[i][col]-=out[k][col]*LU[i][k];
      }
    }
    // solve.default uses machine epsilon as its computational-singularity tolerance.
    // The explicit inverse is already available, so use its one-norm condition bound.
    var normA=0,normInv=0;
    for(var j=0;j<n;j++) {
      var sa=0,si=0;
      for(var i=0;i<n;i++){sa+=Math.abs(A[i][j]);si+=Math.abs(out[i][j]);}
      normA=Math.max(normA,sa);normInv=Math.max(normInv,si);
    }
    var reciprocalCondition=(1/normA)/normInv;
    if(!(reciprocalCondition>=Number.EPSILON)) throw new Error("RVE: computationally singular X'WX");
    return out;
  }
