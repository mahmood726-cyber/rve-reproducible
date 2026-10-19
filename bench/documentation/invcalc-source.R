function (X, W, k) 
{
    sWX <- sqrt(W) %*% X
    res.qrs <- qr.solve(sWX, diag(k))
    return(tcrossprod(res.qrs))
}
