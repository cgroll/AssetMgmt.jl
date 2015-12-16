abstract FullStrategy

type SeparateTurnover <: FullStrategy
    OptStrat::InitialStrategy
    TurnOvStrat::TOFilter

    function SeparateTurnover(strat::InitialStrategy,
                              toStrat::TOFilter)
        return new(strat, toStrat)
    end
end

##################
## optimizeWgts ##
##################

## without history
##----------------

## without investment history (initial investment)
function optimizeWgts(strat::AssetMgmt.SeparateTurnover,
                      univ::AssetMgmt.MuSigmaUniverse)

    ## first get ideal weights without transaction costs
    idealWgts = optimizeWgts(strat.OptStrat, univ)

    return idealWgts
end

## regular case
##-------------

## case: ThresHoldDeviance Filter

## Note: any given TOFilter should work for all initial optimization
## strategies -> parametric type
function optimizeWgts(strat::AssetMgmt.SeparateTurnover,
                      univ::AssetMgmt.MuSigmaUniverse,
                      invHistory::Investments)
    
    ## first get ideal weights without transaction costs
    idealWgts = optimizeWgts(strat, univ)
    
    ## get last morning weights
    ## TODO: invHistory[end, :] returns DataFrame!!
    lastDate = idx(invHistory)[end]
    invTm = convert(Timematr, invHistory)
    lastWeights = asArr(invTm[lastDate, :], Float64, NaN)

    ## get corresponding return data
    rets = asArr(univ.Data[lastDate, :], Float64, NaN)
    
    ## calculate current weights after daily evolution
    eveningWgts = evolWgtsCore(lastWeights, rets)
    
    ## check deviance between real weights and desired weights
    wgtsDeviance = sum(abs(idealWgts[:] .- eveningWgts[:]))
    display(wgtsDeviance)
    if wgtsDeviance > strat.TurnOvStrat.thres
        ## println("rebalancing wgts:")
        ## display(idealWgts)
        return idealWgts
    else
        ## println("evolving wgts:")
        ## display(eveningWgts)
        return eveningWgts
    end
end

###################
## applyStrategy ##
###################

function applyStrategy(strat::AssetMgmt.FullStrategy,
                       estimator::Type{AssetMgmt.ExpWeighted},
                       data::Timematr)
    ## indicator for initial investment
    initialInv = true
    
    ## iterate over dates
    allDats = idx(data)
    nDats = length(allDats)
    
    ## preallocation
    nObs, nAss = size(data)
    allWgts = Array(Float64, nObs, nAss)
    pfMoments = Array(Float64, nObs, 2)
    modelEstimated = falses(nObs)
    
    for ii=1:nDats
        thisDate = allDats[ii]
        univ = AssetMgmt.estimate(estimator, data, thisDate)
        if AssetMgmt.isDef(univ)
            if initialInv
                wgts = AssetMgmt.optimizeWgts(strat, univ)
                initialInv = false
            else
                ## get history
                wgtsHist = allWgts[modelEstimated, :]

                dateHist = allDats[modelEstimated]
                wgtsHistDf = composeDataFrame(wgtsHist, names(data))
                invHistory = AssetMgmt.Investments(wgtsHistDf,
                                         dateHist)

                ## optimize with given history
                wgts = AssetMgmt.optimizeWgts(strat, univ, invHistory)

            end

            ## set estimation indicator to true
            modelEstimated[ii] = true

            allWgts[ii, :] = wgts

            ## calculate portfolio moments
            pfMu = AssetMgmt.getPMean(wgts[:], univ.Universe.mu)
            pfSigma = sqrt(AssetMgmt.getPVar(wgts[:], univ.Universe.sigma))
            pfMoments[ii, :] = [pfMu pfSigma]
        end
    end

    ## remove non-estimatable dates
    allWgts = allWgts[modelEstimated, :]
    pfMoments = pfMoments[modelEstimated, :]
    allDats = allDats[modelEstimated]

    ## DataFrame
    wgtsDf = composeDataFrame(allWgts, names(data))
    pfMomentsDf = Timematr(pfMoments, [:mu, :sigma], allDats)
    
    invs = Investments(wgtsDf, allDats)

    return invs, pfMomentsDf
end


## example:
## investment strategy could be a certain MaxMu plain Markowitz
## strategy together with slow moving turnover constraint

## Turnover filter:
## - each second period only
## - convex combination between current and desired portfolio
## - threshold: only if too far off
## 	- in terms of weight differences
##    - in terms of mu-sigma differences



##############
## old code ##
##############


## function randHolding(discRet::Timematr)
##     ## create random weights and hold them without re-balancing 

## end

## function randInvestments(discRet::Timematr)
##     ## create random investments for given returns
##     nams = names(discRet)
    
##     (nObs, nAss) = size(discRet)

##     wgts = randWgts(nObs, nAss)
##     df = convert(DataFrame, wgts)
##     rename!(df, names(df), nams)

##     return AssetMgmt.Investments(df, idx(discRet))
## end

## function equWgtInvestments(discRet::Timematr)
##     ## create equal weights investments for given returns
##     nams = names(discRet)

##     (nObs, nAss) = size(discRet)

##     wgts = 1/nAss * ones(nObs, nAss)
##     df = convert(DataFrame, wgts)
##     rename!(df, names(df), nams)

##     return AssetMgmt.Investments(df, idx(discRet))
## end

## function gmvSampleMoments(minDays, increasingSample)

##     ## estimation framework:
##     ## - minimum number of days?
##     ## - increasing sample size?
##     ## 

## end
