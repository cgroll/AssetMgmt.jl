function empiricalEstimator(discRet::Array{Float64, 2})
    ## for given data, apply estimator

    mus = mean(discRet)
    covMatr = cov(discRet)

    return (mus, covMatr)
end

function applyEstimator(discRet::Timematr, estFunc::Function,
                        minObs::Int; rollingWindow=false)
    ## apply estimator to data
    ##
    ## Inputs:
    ## 	discRet			Array{Float64, 2} of discrete returns
    ## 	estFunc 			function with Array{Float64, 2} discrete
    ## 						returns as only input
    ## 	minObs			minimum number of observations required for
    ## 						estimation procedure
    ## 	rollingWindow	optional: default value is false, so that
    ## 						estimation procedure makes use of complete
    ## 						data sample
    

    nObs = size(discRet, 2)
    for ii=minObs:nObs
        if rollingWindow
            produce(estFunc(discRet[(ii-minObs+1):ii, :]), idx(discRet)[ii])
        else
            produce(estFunc(discRet[1:ii, :]), idx(discRet)[ii])
        end
    end
end

Task(() -> applyEstimator(discRet, estFunc, minObs,
                          rollingWindow))
function getMarkowitzWgts(t::Task)

    ## get number of wgts and preallocate storage for Array{Float64, 2}
    
    for x in t
        
        ## get mu / sigma values
        (mus, covMatr) = consume(x)

        ## get associated weights
        wgts = gmv(mus, covMatr)

        ## 

    end

    ## transform Array{Float64, 2} to Timematr, filling values from
    ## end

end
