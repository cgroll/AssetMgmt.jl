################################
## filters to reduce turnover ##
################################

## all filters should be functions that receive an Investments object
## of intended portfolio weights as well as an associated Timematr
## object containing asset returns (in order to be able to derive
## automatic portfolio weight evolutions)
##
## function filterName(invs::Investments, tm::Timematr; opts="frequency")
##
## 	return filtWeights # invs object
## end

## various filters:
## - based on ranges (if deviation from desired wgts is too large,
## 	automatic trading will occur to bring weights back to
## 	permitted ranges)
## - based on rebalancing frequencies: rebalance each n days
## - based on overall distance to desired weights
## - combination of all

function regularRB(invs::Investments, discRet::Timematr; freq=30)
    ## rebalance each "freq" days

    ## check inputs
    AssetMgmt.chkMatchInvData(invs,discRet)

    ## extract core values
    wgts = AssetMgmt.core(invs)
    rets = core(discRet)
    (nObs, nAss) = size(wgts)

    ## invRets = invRetCore(wgts, rets)
    
    filteredWgts = zeros(nObs, nAss)
    filteredWgts[1, :] = wgts[1, :]
    for ii=2:nObs

        ## is it time to rebalance?
        timeToRebalance = false
        if mod(ii, freq) == 0
            timeToRebalance = true
        end
        
        if timeToRebalance
            filteredWgts[ii, :] = wgts[ii, :]
        else
            ## get portfolio return
            pfRet = sum(filteredWgts[ii-1, :] .* rets[ii-1, :])
            
            filteredWgts[ii, :] = filteredWgts[ii-1, :] .*
            (1 .+ rets[ii-1, :]) ./ (1 .+ pfRet)
        end
    end
    wgtsDf = composeDataFrame(filteredWgts, names(discRet))

    return Investments(wgtsDf, idx(invs))
end
