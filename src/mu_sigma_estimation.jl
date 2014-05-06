function produceEmpiricalMoments(discRet::Timematr, minObs;
                                 rolling=false)

    nObs = size(discRet, 1)

    ## specify how subsamples should be created
    produceSubsamples =
        Task(() -> AssetMgmt.subsampleProducer(nObs, minObs))

    dataArr = core(discRet)

    for subsample in produceSubsamples
        indices = subsample
        (mu, covMatr) = AssetMgmt.empiricalEstimator(dataArr)
        nextDay = indices[2]+1
        produce(mu, covMatr, nextDay)
    end
end
    
function empiricalEstimator(discRet::Array{Float64, 2})
    ## for given data, apply estimator

    mus = mean(discRet, 1)
    covMatr = cov(discRet)

    return (mus, covMatr)
end

## function applyEstimator(discRet::Timematr, estFunc::Function,
##                         responseFunc::Function,
##                         minObs::Int; auxData=(), rollingWindow=false)
##     ## apply estimator to data
##     ##
##     ## Inputs:
##     ## 	discRet			Array{Float64, 2} of discrete returns
##     ## 	estFunc 			function with Array{Float64, 2} discrete
##     ## 						returns as only input
##     ## 	minObs			minimum number of observations required for
##     ## 						estimation procedure
##     ## 	rollingWindow	optional: default value is false, so that
##     ## 						estimation procedure makes use of complete
##     ## 						data sample

##     valsDf = DataFrame(size(discRet)...)
##     rename!(valsDf, names(valsDf), names(discRet))
##     invs = Timedata(valsDf, idx(discRet))
        
##     nObs = size(discRet, 1)
##     t = Task(() -> subsamples(nObs, minObs, rollingWindow=rollingWindow))

##     ## get data as array
##     discRetArr = core(discRet)

##     auxDataArr = ()
##     for ii=1:length(auxData)
##         auxDataArr = tuple(auxDataArr..., core(auxData[ii]))
##     end

##     for x in t
##         indices = x
##         println(indices)

##         ## get auxilliary data
##         getAux = x -> getindex(x, indices[1]:indices[2],
##                                1:size(x,2))
##         outp = ()
##         for ii=1:length(auxData)
##             outp = tuple(outp..., getAux(auxDataArr[ii]))
##         end
##         (mus, covMatr) = estFunc(discRetArr[indices[1]:indices[2], :],
##                                  outp...)

##         ## get weights
##         wgts = responseFunc(mus, covMatr)

##         ## capture calculated weights
##         invs.vals[(indices[2]+1), :] = wgts
        
##     end
##     return invs
## end

## estFunc = empiricalEstimator
## responseFunc = AssetMgmt.gmv
## applyEstimator(discRet, estFunc, responseFunc, 1500)

## function getMarkowitzWgts(t::Task)

##     ## get number of wgts and preallocate storage for Array{Float64, 2}
##     for x in t
##         ## get mu / sigma values
##         (mus, covMatr) = consume(x)
##         ## get associated weights
##         wgts = gmv(mus, covMatr)
##     end

##     ## transform Array{Float64, 2} to Timematr, filling values from
##     ## end
## end


