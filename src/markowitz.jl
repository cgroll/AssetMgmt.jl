function gmv(mus::DataFrame, covMatr::DataFrame)
    ## global minimum variance portfolio
    nAss = size(mus, 2)

    oneArr = ones(nAss)
    invCov = inv(array(covMatr))
    wgts = 1/(oneArr'*invCov*oneArr).*invCov*oneArr

    return wgts'
end
    
function gmv(mus::Array{Float64, 2}, covMatr::Array{Float64, 2})
    ## global minimum variance portfolio
    nAss = size(mus, 2)

    oneArr = ones(nAss)
    invCov = inv(covMatr)
    wgts = 1./(oneArr'*invCov*oneArr).*invCov*oneArr

    return wgts'
end
    
function maxSharpeRatio(mus::Array{Float64, 2},
                        covMatr::Array{Float64, 2},
                        r::Float64)
    ## calculate portfolio weights that maximize Sharpe ratio
    ##
    ## Inputs:
    ## 	mus			1 x nAss Array{Float64, 2} of asset mus
    ## 	covMatr		nAss x nAss Array{Float64, 2} of asset
    ## 					covariances 
    ## 	r				Float64 for annualized interest rate
    ##
    ## Outputs:
    ## 	1 x nAss Array{Float64, 2} of optimal portfolio weights

    ## transform to daily interest rate
    intRate = (1 + r)^(1/250) - 1

    ## number of assets
    nAss = size(mus, 2)

    ## Array{Float64, 2} expected daily excess returns
    muExcess = (mus .- intRate)[:]

    oneArr = ones(nAss)
    invCov = inv(covMatr)
    wgts = 1./(oneArr'*invCov*muExcess).*invCov*muExcess

    return wgts'
end
