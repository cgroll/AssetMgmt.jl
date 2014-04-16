#########################################
## check convex combination constraint ##
#########################################

const precision = 1e-9
function chkEqualsOne(x::Array{Float64, 1})
    if(abs(sum(x) - 1) > precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(x::Array{Float64, 2})
    if size(x, 2) == 1
        if(abs(sum(x) .- 1) > precision)
            error("weights must sum to one")
        end
    else 
        if any(abs(sum(x, 2) .- 1) .> precision)
            error("weights must sum to one")
        end
    end
end

function chkEqualsOne(df::DataFrame)
    rowSums = sum(array(df), 2)

    if any(abs(rowSums) .- 1 .> precision)
        error("weights must sum to one")
    end
end

function chkEqualsOne(tm::Timematr)
    rowSums = sum(core(tm), 2)

    if any(abs(rowSums) .- 1 .> precision)
        error("weights must sum to one")
    end
end

function makeWeights(matr::Array{Float64, 2})
    ## normalize matrix to have row sums of 1
    nObs = size(matr, 1)
    for ii=1:nObs
        matr[ii, :] = matr[ii, :]./sum(matr[ii, :])
    end
    return matr
end

function chkNumDf(df::DataFrame)
    n = ncol(df)
    for ii=1:n
        ## check for numeric values
        if(!issubtype(types(df)[ii], Number))
            error("all columns must be numeric for conversion")
        end
        if(issubtype(types(df)[ii], Bool))
            error("all columns must be numeric for conversion")
        end
    end
end

function chkNum(df::DataFrame)
    if any(isna(df))
        error("no NAs allowed in Portfolios or Investments")
    end
    chkNumDf(df)
end

###############################################
## check matching investment and return data ##
###############################################

function chkMatchInvData(invs::Investments, discRet::Timematr)
    ## test whether investments and return data are matching

    ## check for conforming dates and assets
    if AssetMgmt.idx(invs) != idx(discRet)
        error("indices / dates of investments and returns must
coincide")
    end

    if AssetMgmt.names(invs) != names(discRet)
        error("asset names of investments and returns must coincide")
    end
end

######################
## evolving weights ##
######################

function evolWgts(invs::Investments, discRet::Timematr)
    ## calculate evolving weights without re-balancing
    ## evolved weights preserve dates -> interpretation: new weights
    ## at the end of the same day

    chkMatchInvData(invs, discRet)

    invRets = AssetMgmt.invRet(invs, discRet)
    invRets = core(invRets)
    rets = core(discRet)
    wgts = AssetMgmt.core(invs)

    weightsDueToPriceChanges = zeros(size(invs))
    for ii=1:size(invs, 1)
        weightsDueToPriceChanges(ii, :) = wgts[ii, :] .*
        (1 + discRet[ii, :]) ./ (1 + invRets[ii])
    end

    wgtsPriceChanges = composeDataFrame(weightsDueToPriceChanges,
                                        names(discRet)) 
    
    return AssetMgmt.Investments(wgtsPriceChanges, idx(discRet))
end
