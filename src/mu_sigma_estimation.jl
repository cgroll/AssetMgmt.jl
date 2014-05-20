## general interface:
## - specify minimum size of sample and whether rolling window should
##   be applied
## - specify function to estimate and auxilliary data required for
##   estimator
##
## each estimator function signature should be:
## (discRet, begInd, endInd, auxData)

#######################
## general interface ##
#######################

function produceMoments(discRet::Timematr,
                        estimator::Function,
                        auxData::Tuple;
                        minObs=200, rolling=false)
    ## produce estimated moments for subsample, and return them as
    ## estimate for next day after subsample
    ##
    ## Inputs:
    ## 	discRet 		nObs x nAss Timematr of discrete returns
    ## 	estimator	estimator function that shall be applied to each
    ## 					subsample
    ## 	auxData 		1 x nAux tuple of auxiliary data used to impose
    ## 					structure within estimator
    ## 	minObs 		define (minimum) number of observations per
    ## 					estimate: first day that estimate is produced,
    ## 					and subsample size for rolling window approach
    ## 	rolling		Boolean value to indicate whether rolling window
    ## 					approach will be used or not
    ##
    ## Outputs:
    ## 	tuple (mu, covMatr, nextDay) with estimated moments for given
    ## 	subsample and scalar index of next day, where estimated
    ## 	moments will be used for to build a strategy at the next day
    
    ## general interface to moments estimation
    nObs = size(discRet, 1)

    ## specify how subsamples should be created
    produceSubsamples =
        Task(() -> AssetMgmt.subsampleProducer(nObs, minObs))

    dataArr = core(discRet)

    for subsample in produceSubsamples
        indices = subsample
        (mu, covMatr) = estimator(dataArr, indices..., auxData...)
        nextDay = indices[2]+1
        produce(mu, covMatr, nextDay)
    end
end

#######################
## empirical moments ##
#######################

function empiricalEstimator(discRet::Array{Float64, 2},
                            begInd::Int,
                            endInd::Int)
    ## for given data, apply estimator

    mus = mean(discRet[begInd:endInd, :], 1)
    covMatr = cov(discRet[begInd:endInd, :])

    return (mus, covMatr)
end

###################
## factor models ##
###################



