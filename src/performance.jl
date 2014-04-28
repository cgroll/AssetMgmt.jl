########################
## investment returns ##
########################

function invRet(invs::Investments, discRet::Timematr; name = :pRet)
    ## calculate portfolio returns for equal dates and assets
    ##
    ## Inputs:
    ## 	invs 		nObs x nAss portfolio weights over time
    ## 	discRet	nObs x nAss discrete portfolio returns
    ## 	name 		optional: Symbol containing column name for
    ## 				investment returns. default value is :pRet.
    ## 
    ## Output:
    ## 	nObs x 1 Timematr of portfolio returns over time 

    ## checking for matching weights and data
    AssetMgmt.chkMatchInvData(invs,discRet)
    
    wgts = AssetMgmt.core(invs)
    rets = core(discRet)

    portRet = AssetMgmt.invRetCore(wgts, rets)
    invDf = DataFrame(pfRet = portRet[:])

    ## rename portfolio return according to strategy name
    rename!(invDf, names(invDf), [name])

    return Timematr(invDf, idx(discRet))
end

function invRetCore(wgts::Array{Float64,2}, rets::Array{Float64,2})
    ## calculate portfolio returns
    ## low-level function not to be called directly!
    ##
    ## Inputs:
    ## 	wgts 		nObs x nAss portfolio weights over time
    ## 	rets		nObs x nAss discrete portfolio returns
    ## 
    ## Output:
    ## 	nObs x 1 Array{Float64, 1} of portfolio returns over time 

    return portRet = sum(wgts .* rets, 2)
end

######################
## evolving weights ##
######################

function evolWgtsCore(wgts::Array{Float64,2},
                      rets::Array{Float64,2})
    ## calculate evolving weights without re-balancing
    ## low-level function not to be called directly!
    ## Inputs:
    ## 	wgts 		nObs x nAss portfolio weights
    ## 	rets 		nObs x nAss discrete portfolio returns
    ##
    ## Output:
    ## 	nObs x nAss Array{Float64, 2} containing evolved portfolio 
    ## 	weights at the end of each day

    invRets = invRetCore(wgts, rets)
    
    weightsDueToPriceChanges = zeros(size(wgts))
    for ii=1:size(rets, 1)
        weightsDueToPriceChanges[ii, :] = wgts[ii, :] .*
        (1 .+ rets[ii, :]) ./ (1 .+ invRets[ii])
    end

    return weightsDueToPriceChanges
end

function evolWgts(invs::Investments, discRet::Timematr)
    ## calculate evolving weights without re-balancing
    ## 
    ## evolved weights preserve dates -> interpretation: new weights
    ## at the end of the same day
    ##
    ## Inputs:
    ## 	invs 		nObs x nAss Investments object
    ## 	discRet	nObs x nAss Timematr with discrete portfolio returns 
    ## 
    ## Output:
    ## 	nObs x nAss Investments object containing evolved portfolio
    ## 	weights at the end of each day

    chkMatchInvData(invs, discRet)

    weightsDueToPriceChanges = evolWgtsCore(AssetMgmt.core(invs),
                                            core(discRet)) 

    wgtsPriceChanges = composeDataFrame(weightsDueToPriceChanges,
                                        names(discRet)) 
    
    return AssetMgmt.Investments(wgtsPriceChanges, idx(discRet))
end


#########################
## investment turnover ##
#########################

function turnover(invs::Investments, discRet::Timematr)
    ## calculate daily turnover to run investment strategy -
    ## automatically evolving portfolio weights due to evolution of
    ## prices taken into account.
    ##
    ## turnover is define as sum of absolute differences
    ##
    ## Inputs:
    ## 	invs 		nObs x nAss investment weights
    ## 	discRet	nObs x nAss discrete asset returns
    ## 
    ## Output:
    ## 	nObs x 1 Timematr of daily portfolio turnover

    AssetMgmt.chkMatchInvData(invs,discRet)
    invsArr = AssetMgmt.core(invs)

    ## get automatic daily changes of weights
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

function intendedTurnover(invs::Investments)
    ## calculate turnover due to intended rebalancing without
    ## consideration of weight evolutions
    ##
    ## Inputs:
    ## 	invs 		nObs x nAss portfolio weights intended to occur
    ## 				without transaction costs
    ## Output:
    ## 	nObs x 1 Timematr of daily portfolio turnover

    invsArr = AssetMgmt.core(invs)

    nObs = size(invs, 1)
    tOver = zeros(nObs, 1)

    for ii=2:nObs
        tOver[ii, 1] = sum(abs(invsArr[ii, :] - invsArr[ii-1, :]))
    end

    tOverDf = DataFrame()
    tOverDf[:intTurnOver] = tOver[:]
    return Timematr(tOverDf, idx(invs))
end

##################################
## investment return statistics ##
##################################

type retStat
    name::Symbol
    mu::Float64
    median::Float64
    sigma::Float64
    VaR95::Float64
    VaR99::Float64
    VaR995::Float64
end

function returnStatistics(tm::Timematr)
    ## calculate statistic on return series
    
    if size(tm, 2) > 1
        error("returnStatistics only works for single asset yet") 
    end

    rets = core(tm)

    mu = mean(rets)
    sigma = std(rets)
    (median, VaR95, VaR99, VaR995) = quantile(rets[:], [0.5; 0.05; 0.01; 0.005])

    return retStat(names(tm)[1], mu, median, sigma, VaR95, VaR99, VaR995)
end



