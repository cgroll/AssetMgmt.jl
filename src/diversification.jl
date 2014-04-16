function diversificationCore(wgts::Array{Float64, 2})
    ## calculates several diversification measures
    ## Note: low-level function not to be called directly!
    ## 
    ## Inputs:
    ## 	wgts 	nObs x nAss matrix of portfolio weights
    ##
    ## Outputs:
    ## 	DataFrame containing information on number of assets
    ## 	divIndicators table containing information on number of
    ## 	assets, number of significant assets, maximum weight, 
    ## 	standard deviation of weights, number of negative
    ## 	weights and gini coefficient (herfindahl) for each day

    ## tolerance level for significant assets
    sigLev = 0.0001;

    ## transpose if column vector
    if size(wgts, 2) == 1
        wgts = wgts'
    end

    ## basic statistics
    nAss = sum(wgts .!= 0, 2);
    nSignAss = sum(abs(wgts .- 0) .> sigLev, 2)
    maxWgt = maximum(wgts, 2)
    stdWgt = std(wgts, 2)
    nShort = sum(wgts .< 0, 2)

    ## gini coefficient with negative weights
    absExposure = sum(abs(wgts), 2);
    relExposures = wgts ./ repmat(absExposure, 1, size(wgts, 2)) 
    gini = sum(relExposures.^2, 2);

    divIndicators = DataFrame()
    divIndicators[:nAss] = nAss[:]
    divIndicators[:nSignAss] = nSignAss[:]
    divIndicators[:maxWgt] = maxWgt[:]
    divIndicators[:stdWgt] = stdWgt[:]
    divIndicators[:nShort] = nShort[:]
    divIndicators[:Gini] = gini[:]

    return divIndicators
end

function diversification(invs::Investments)
    ## calculates several diversification measures
    ## 
    ## Inputs:
    ## 	wgts 	nObs x nAss matrix of portfolio weights
    ##
    ## Outputs:
    ## 	DataFrame containing information on number of assets
    ## 	divIndicators table containing information on number of
    ## 	assets, number of significant assets, maximum weight, 
    ## 	standard deviation of weights, number of negative
    ## 	weights and gini coefficient (herfindahl) for each day

    wgts = AssetMgmt.core(invs)

    divIndicators = diversificationCore(wgts)
    return Timematr(divIndicators, AssetMgmt.idx(invs))
end
