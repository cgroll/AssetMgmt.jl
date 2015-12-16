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
    rets = core(discRet[idx(invs), :])

    portRet = AssetMgmt.invRetCore(wgts, rets)
    invDf = DataFrame(pfRet = portRet[:])

    ## rename portfolio return according to strategy name
    rename!(invDf, names(invDf), [name])

    return Timematr(invDf, idx(invs))
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

    ## get returns on dates of investments
    relevantRets = discRet[idx(invs), :]

    weightsDueToPriceChanges = evolWgtsCore(AssetMgmt.core(invs),
                                            core(relevantRets)) 

    wgtsPriceChanges = composeDataFrame(weightsDueToPriceChanges,
                                        names(discRet)) 
    
    return AssetMgmt.Investments(wgtsPriceChanges, idx(invs))
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

    ## get automatic daily changes of weights
    wgtsPriceChanges = evolWgts(invs, discRet)

    ## get values without metadata
    invsArr = AssetMgmt.core(invs)
    wgtsPriceChangesArr = AssetMgmt.core(wgtsPriceChanges)

    ## preallocate turnover
    nObs = size(invs, 1)
    tOver = zeros(nObs, 1)

    ## get trading days
    tradingIndices = find(isTradingDay(invs, discRet))

    ## skip first day
    tradingIndices = tradingIndices[2:end]
    
    for iDay in tradingIndices
        tOver[iDay, 1] =
            sum(abs(invsArr[iDay, :] -
                    wgtsPriceChangesArr[iDay-1, :]))
    end

    ## return turnover as Timematr
    tOverDf = DataFrame()
    tOverDf[:turnOver] = tOver[:]
    return Timematr(tOverDf, idx(invs))
end

function intendedTurnover(invs::Investments, discRet::Timematr)
    ## intended turnover is the difference between morning weights of
    ## a trading day and the last trading day. should equal
    ## weightFluctuations if applied to initialStrategies.

    ## get values without metadata
    invsArr = AssetMgmt.core(invs)

    ## preallocate turnover
    nObs = size(invs, 1)
    tOver = zeros(nObs, 1)

    ## get trading days
    tradingIndices = find(isTradingDay(invs, discRet))

    for ii=2:length(tradingIndices)
        currTradingDay = tradingIndices[ii]
        lastTradingDay = tradingIndices[ii-1]
        tOver[currTradingDay, 1] =
            sum(abs(invsArr[currTradingDay, :] -
                    invsArr[lastTradingDay, :]))
    end

    ## return turnover as Timematr
    tOverDf = DataFrame()
    tOverDf[:turnOver] = tOver[:]
    return Timematr(tOverDf, idx(invs))
end

function weightFluctuations(invs::Investments)
    ## calculate absolute weight changes for "morning" weights - no
    ## consideration of weight changes due to price changes
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

######################
## maximum drawdown ##
######################

function maxDD(discRet::Timematr)
    ## calculate maximum percentage drawdown and time of occurrence
    ##
    ## Inputs:
    ## 	discRet		nObs x 1 Timematr of discrete returns
    ##
    ## Output:
    ## 	(percentDD, ddPeriod) tuple
    ## 	percentDD 	scalar value of percentage return achieved during
    ## 					maximum drawdown period
    ## 	ddPeriod		data for subinterval of maximum drawdown
    ##
    ## Note: function is based on algorithm described in
    ## http://en.wikipedia.org/wiki/Drawdown_%28economics%29 

    ## only implemented for one asset at a time
    (nObs, nAss) = size(discRet)
    if nAss > 1
        error("Only one asset allowed: discRet must be single column")
    end
    
    ## get cumulated returns
    normedPrices = cumprod(discRet .+ 1, 1)

    ## init variables
    drawdowns = zeros(nObs)
    maxDD = 0;
    highestValueSoFar = -99999;
    highestValueSoFarIdx = 0;    
    ddStartIdx = 0;
    ddEndIdx = 0;

    # for each day, measure percentage loss to previous peak
    for ii = 1:nObs
        if normedPrices[ii] > highestValueSoFar
            # if current value is new peak, it can not be the end of
            # maximum drawdown period, because drawdown up to this
            # peak would be a positive value
            highestValueSoFar = normedPrices[ii]
            highestValueSoFarIdx = ii
        else
            drawdowns[ii] = (highestValueSoFar - normedPrices[ii]) / 
                             highestValueSoFar
        end

        if drawdowns[ii] > maxDD
            # if largest drawdown so far
            maxDD = drawdowns[ii]
            ddEndIdx = ii
            ddStartIdx = highestValueSoFarIdx
        end
    end
end
    
