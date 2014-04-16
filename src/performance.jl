## portfolio return
function invRet(invs::Investments, discRet::Timematr)
    ## calculate portfolio returns for equal dates and assets

    AssetMgmt.chkMatchInvData(invs,discRet)
    
    wgts = AssetMgmt.core(invs)
    rets = core(discRet)

    portRet = sum(wgts .* rets, 2)
    invDf = AssetMgmt.composeDataFrame(portRet, names(discRet))

    return Timematr(invDf, idx(discRet))
end


## turnover
function turnover(invs::Investments, discRet::Timematr)
    ## calculate daily turnover to run investment strategy

    AssetMgmt.chkMatchInvData(invs,discRet)

    wgtsPriceChanges = evolWgts(invs, discRet)

    nObs = size(invs, 1)
    tOver = zeros(nObs, 1)
    for ii=2:nObs
        tOver[ii] = abs(invs[ii, :] - wgtsPriceChanges[ii-1, :])
    end

    return Timematr(tOver, idx(discRet))
end




