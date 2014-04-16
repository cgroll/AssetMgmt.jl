## portfolio return
function invRet(invs::Investments, discRet::Timematr)
    ## calculate portfolio returns for equal dates and assets
    ## Output:
    ## 	nObs x 1 Timematr of portfolio returns over time 

    AssetMgmt.chkMatchInvData(invs,discRet)
    
    wgts = AssetMgmt.core(invs)
    rets = core(discRet)

    portRet = AssetMgmt.invRetCore(wgts, rets)
    invDf = DataFrame(pfRet = portRet[:])

    return Timematr(invDf, idx(discRet))
end

function invRetCore(wgts::Array{Float64,2}, rets::Array{Float64,2})
    ## calculate portfolio returns
    ## low-level function not to be called directly!
    ## 
    ## Output:
    ## 	nObs x 1 Array{Float64, 1} of portfolio returns over time 

    return portRet = sum(wgts .* rets, 2)
end


## turnover
function turnover(invs::Investments, discRet::Timematr)
    ## calculate daily turnover to run investment strategy
    ## Output:
    ## 	nObs x 1 Timematr of daily portfolio turnover

    AssetMgmt.chkMatchInvData(invs,discRet)
    invsArr = AssetMgmt.core(invs)

    wgtsPriceChanges = evolWgts(invs, discRet)
    wgtsPriceChangesArr = AssetMgmt.core(wgtsPriceChanges)
    
    nObs = size(invs, 1)
    tOver = zeros(nObs, 1)

    for ii=2:nObs
        tOver[ii, 1] = sum(abs(invsArr[ii, :] - wgtsPriceChangesArr[ii-1, :]))
    end

    tOverDf = DataFrame()
    tOverDf[:turnOver] = tOver[:]
    return Timematr(tOverDf, idx(discRet))
end



