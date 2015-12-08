abstract InvestmentStrategy

type SeparateTurnover{T, S}
    OptStrat::T
    TurnOvStrat::S
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
